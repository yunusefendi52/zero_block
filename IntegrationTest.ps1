param(
    $Target = "web"
)

if ($Target -eq "web") {
    $ChromeDriverPath = "/usr/local/share/chrome_driver" # hosted on azure/actions
    if (!(Test-Path $ChromeDriverPath -PathType Leaf)) {
        $ChromeDriverPath = "$env:HOME/tools/chromdriver/chromedriver"
    }
    Start-Process $ChromeDriverPath -ArgumentList "--port=4444" -PassThru -NoNewWindow
    Start-Sleep -Milliseconds 175 # do I have to?
    flutter drive --driver=test_driver/integration_test.dart --target=integration_test/level_test.dart -d web-server
}
