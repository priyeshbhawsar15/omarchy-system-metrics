function chooseScreen(screens, targetName) {
    var target = screens.find(function(screen) { return screen.name === targetName })
    return target || screens[1] || screens[0] || null
}
