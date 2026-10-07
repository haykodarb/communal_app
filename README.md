# Communal

A semi-decentralized library for sharing physical books between people who know each other.

The project is made for those of us who enjoy collecting books but who also wish to share them with the people around us. Sharing happens between people who know each other IRL and can trust each other with their items.

Once the book sharing part is complete, I'd like to extend the app towards sharing tools and other physical objects, to build a sort of semi-decentralized "maker space", since most of us who like building things usually buy tools that spend most of their time sitting idly in a storage room.

## How it works

The app started out with manually created communities (a group of neighbours, a reading club, a college class...). It has since moved to an organic friends-of-friends network: your community is the people you know and the people they know.

- You see your friends' books, and the books of your friends' friends if they opted in ("Show my books to friends of friends" in Account settings). Nothing is visible beyond two hops.
- Books from friends of friends show who connects you ("via ...").
- You request a book, the owner accepts, you coordinate the handover over chat, and you return it with an optional review.
- If a book is currently loaned you can join its waitlist and get notified when it's available.

Communities are still in the code but hidden from the app.

## Status

Version 0.3.4. Working:

- Accounts: register, login, password recovery, email/password change, account deletion.
- Profiles with avatar, bio and email visibility; mutual friends on other people's profiles.
- Friends page (friends, received and sent requests) with a pending-requests badge.
- My Books: add, edit, delete books with covers and the owner's review.
- Search: books across your network and users by username.
- Loans: request, accept/reject, return, review, loan timeline, message the other person.
- Waitlist for loaned books.
- Messages with realtime updates and read receipts.
- Notifications (in app and push on mobile).
- English and Spanish.

Visibility is enforced by Row Level Security in Supabase, not only by the client.

## Repositories

- `communal_app` (this repo): the Flutter app (Android, iOS, web).
- `communal_web`: a SvelteKit port of this app with the same features, plus the landing page. The web version lives there.
- `communal_server`: Supabase schema backups.

## Developed With

Flutter on the frontend and Supabase (Postgres, Auth, Storage, Realtime) as the backend. Push notifications go through Firebase Cloud Messaging.

The Flutter app has been and will continue to be fully open source and its development will be conducted in this repository.

The Supabase database will be open sourced once it's stable and I figure out how to package the Postgres database. Ideally I'll build it as a self-hostable Docker instance, but it's extra work that I'm not willing to do until the project is usable and tested.

### Running

A Nix flake provides Flutter and the Android SDK:

```sh
nix develop
flutter pub get
flutter run                        # device or emulator
flutter run -d web-server --web-port 8080
```

## Roadmap

1. **Invite links**: an "Invite a friend" link that creates the friendship when the invitee signs up, and an onboarding prompt to add friends, so new users don't start with an empty app.
2. **Loan return dates**: an expected return date when accepting a loan, plus a reminder when it passes.
3. **ISBN scanning**: fill title, author and cover from Open Library (there's commented-out code in `book_create_controller.dart`).
4. **Notifications outside the app**: web push or email for loan requests and acceptances, and push for "book available" notifications.
5. **Retire communities** if the friends-of-friends direction is final, including their database triggers.

## Known issues

- Flutter web stays blank until the notification permission prompt is answered (`main()` awaits `requestPermission()` before `runApp`).
- Deleting a book doesn't remove its cover from storage (the stored path starts with `/`); deleting a community doesn't remove its avatar.
- The loan timeline shows the request date for every step instead of the accepted/returned dates.
- Book lists can briefly show a stale cover when the list changes.
- Book covers in storage are readable by any logged-in user who has the path.
- Community membership triggers write to a column that no longer exists, so invitations and joins fail (communities are hidden).
- `communal_server/schema_backup.sql` is out of date with production.
