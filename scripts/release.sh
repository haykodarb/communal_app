#!/usr/bin/env bash
# Builds the Android App Bundle and uploads it to Google Play.
#
#   scripts/release.sh                     # internal testing track, as a draft
#   scripts/release.sh --track beta        # or alpha, production
#   scripts/release.sh --status completed  # roll it out instead of a draft
#   scripts/release.sh --check             # only show what's on Play; no build
#
# The version is pubspec.yaml's `version: <name>+<code>`. Play never accepts a
# version code twice, so before building, the script asks Play for the highest
# one it has and stops unless pubspec's is higher: bump the version to release.
# A release is tagged v<name> on the commit it was built from, so the working
# tree must be clean.
#
# Needs the upload keystore (android/key.properties) and the Play service
# account's JSON key, at ../communal_key/play-service-account.json or
# $PLAY_SERVICE_ACCOUNT. curl, jq and openssl come from the dev shell (direnv
# or `nix develop`).
#
# Drafts wait in Play Console (Test and release) until you roll them out.
set -euo pipefail

repo_root="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
cd "$repo_root"

package="ar.communal"
key_file="${PLAY_SERVICE_ACCOUNT:-$repo_root/../communal_key/play-service-account.json}"
aab="build/app/outputs/bundle/release/app-release.aab"
api_base="https://androidpublisher.googleapis.com/androidpublisher/v3/applications/$package"
upload_base="https://androidpublisher.googleapis.com/upload/androidpublisher/v3/applications/$package"

track="internal"
status="draft"
check=false
while [ $# -gt 0 ]; do
	case "$1" in
		--track) track="${2:-}"; shift 2 ;;
		--status) status="${2:-}"; shift 2 ;;
		--check) check=true; shift ;;
		*) echo "!! Unknown option $1" >&2; exit 1 ;;
	esac
done
case "$track" in internal | alpha | beta | production) ;; *)
	echo "!! --track must be internal, alpha, beta or production" >&2; exit 1 ;;
esac
case "$status" in draft | completed) ;; *)
	echo "!! --status must be draft or completed" >&2; exit 1 ;;
esac

for tool in flutter curl jq openssl; do
	command -v "$tool" >/dev/null || { echo "!! $tool not found; run inside the dev shell" >&2; exit 1; }
done
[ -f "$key_file" ] || { echo "!! No service account key at $key_file" >&2; exit 1; }

version="$(sed -n 's/^version: *//p' pubspec.yaml)"
name="${version%%+*}"
code="${version##*+}"
[[ "$code" =~ ^[0-9]+$ ]] || { echo "!! pubspec.yaml's version ($version) has no +<code>" >&2; exit 1; }

# --- Google Play API ---------------------------------------------------------

b64url() { base64 -w0 | tr '+/' '-_' | tr -d '='; }

# OAuth access token from the service account: a JWT signed with its private
# key. The key is piped straight to openssl, never written out.
echo "==> Signing in to Google Play"
now="$(date +%s)"
jwt_header="$(printf '{"alg":"RS256","typ":"JWT"}' | b64url)"
jwt_claims="$(jq -nc --arg iss "$(jq -r .client_email "$key_file")" --argjson iat "$now" '{
	iss: $iss,
	scope: "https://www.googleapis.com/auth/androidpublisher",
	aud: "https://oauth2.googleapis.com/token",
	iat: $iat,
	exp: ($iat + 3600)
}' | b64url)"
jwt_sig="$(printf '%s.%s' "$jwt_header" "$jwt_claims" |
	openssl dgst -sha256 -binary -sign <(jq -r .private_key "$key_file") | b64url)"
token="$(curl -sS -d grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer \
	-d assertion="$jwt_header.$jwt_claims.$jwt_sig" https://oauth2.googleapis.com/token |
	jq -r '.access_token // empty')"
[ -n "$token" ] || { echo "!! Google rejected the service account key" >&2; exit 1; }

# api <curl args...>: prints the response body; fails with Google's message on
# an HTTP error. The token goes through stdin, so it never shows up in ps.
api() {
	local out http
	out="$(curl -sS -K - -w '\n%{http_code}' "$@" <<<"header = \"Authorization: Bearer $token\"")"
	http="${out##*$'\n'}"
	out="${out%$'\n'*}"
	if [ "$http" -ge 400 ]; then
		echo "!! Google Play API: HTTP $http" >&2
		jq -r '.error.message // .' <<<"$out" >&2 || printf '%s\n' "$out" >&2
		return 1
	fi
	printf '%s' "$out"
}
api_json() { api -H 'Content-Type: application/json' "$@"; }

# Every change goes through an edit, which only takes effect on commit. An edit
# left open (by --check, or a failure) is deleted on exit.
edit=""
close_edit() { [ -z "$edit" ] || api -X DELETE "$api_base/edits/$edit" >/dev/null || true; }
trap close_edit EXIT
open_edit() { edit="$(api_json -X POST -d '{}' "$api_base/edits" | jq -r .id)"; }

# --- Check what's on Play -----------------------------------------------------

open_edit
highest="$(
	{
		api "$api_base/edits/$edit/bundles" | jq '.bundles[]?.versionCode'
		api "$api_base/edits/$edit/apks" | jq '.apks[]?.versionCode'
	} | sort -n | tail -n 1
)"
highest="${highest:-0}"

if $check; then
	echo "==> Highest version code on Play: $highest (pubspec.yaml: $version)"
	api "$api_base/edits/$edit/tracks" | jq -r '
		.tracks[] | "    \(.track): " + (
			[.releases[]? | "\(.name // "?") [\(.versionCodes // [] | join(","))] \(.status)"]
			| if length == 0 then "nothing" else join("; ") end
		)'
	exit 0
fi

if [ "$code" -le "$highest" ]; then
	echo "!! Version code $code isn't above Play's highest ($highest)." >&2
	echo "   Bump \"version:\" in pubspec.yaml (e.g. $name+$((highest + 1)))." >&2
	exit 1
fi
close_edit
edit=""

# --- Build and upload ---------------------------------------------------------

if [ -n "$(git status --porcelain)" ]; then
	echo "!! The working tree has uncommitted changes; commit them first." >&2
	exit 1
fi
if git rev-parse -q --verify "refs/tags/v$name" >/dev/null; then
	echo "!! v$name is already tagged; bump the version name in pubspec.yaml." >&2
	exit 1
fi

echo "==> Building $name ($code)"
flutter build appbundle --release

echo "==> Uploading $aab ($(du -h "$aab" | cut -f1))"
open_edit
uploaded="$(api -X POST -H 'Content-Type: application/octet-stream' --data-binary @"$aab" \
	"$upload_base/edits/$edit/bundles?uploadType=media" | jq -r .versionCode)"
[ "$uploaded" = "$code" ] || { echo "!! Play read version code $uploaded, expected $code" >&2; exit 1; }

echo "==> Adding it to the $track track ($status)"
api_json -X PUT "$api_base/edits/$edit/tracks/$track" -d "$(jq -nc \
	--arg track "$track" --arg name "$code ($name)" --arg code "$code" --arg status "$status" \
	'{track: $track, releases: [{name: $name, versionCodes: [$code], status: $status}]}')" >/dev/null

api_json -X POST -d '{}' "$api_base/edits/$edit:commit" >/dev/null
edit=""

git tag -a "v$name" -m "Release $name ($code) to the $track track"

echo "==> Released $name ($code) to the $track track ($status); tagged v$name"
[ "$status" = draft ] && echo "    Roll it out in Play Console: Test and release -> $track."
echo "    Push the tag with: git push origin v$name"
