{{flutter_js}}
{{flutter_build_config}}

// Manipulate the DOM to add a loading spinner will be rendered with this HTML:
// <div class="loading">
//   <div class="loader" />
// </div>
const loadingDiv = document.createElement('div');
loadingDiv.className = "loading-div";
document.body.appendChild(loadingDiv);
const loaderDiv = document.createElement('div');
loaderDiv.className = "loader-spin";
const loaderText = document.createElement('p');
loaderText.innerHTML += "Loading Communal app";
loaderText.className = "loader-text";
loadingDiv.appendChild(loaderText);
loadingDiv.appendChild(loaderDiv);

// Customize the app initialization process
_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();

    // Remove the loading spinner when the app runner is ready
    if (document.body.contains(loadingDiv)) {
      document.body.removeChild(loadingDiv);
    }
    await appRunner.runApp();
  }
});
