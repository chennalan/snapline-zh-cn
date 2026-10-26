# Applies the Simplified Chinese UI patch to a checked-out upstream Snapline source tree.
$ErrorActionPreference = 'Stop'
$stringsPath = Join-Path $PSScriptRoot '..\upstream\src\Snapline\UI\Strings.cs'
$settingsWindowPath = Join-Path $PSScriptRoot '..\upstream\src\Snapline\UI\SettingsWindow.cs'
$settingsPath = Join-Path $PSScriptRoot '..\upstream\src\Snapline\Core\Settings.cs'

foreach ($p in @($stringsPath, $settingsWindowPath, $settingsPath)) {
    if (-not (Test-Path $p)) { throw "Expected upstream source file not found: $p" }
}

$s = Get-Content -Raw -Encoding UTF8 $stringsPath
$old = 'if (chosen is "en" or "ar") return chosen;'
$new = 'if (chosen is "en" or "ar" or "zh-CN") return chosen;'
if (-not $s.Contains($old)) { throw 'Could not find language selection logic in Strings.cs; upstream may have changed.' }
$s = $s.Replace($old, $new)
$old = 'return CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "ar" ? "ar" : "en";'
$new = 'return CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "ar" ? "ar" : CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "zh" ? "zh-CN" : "en";'
if (-not $s.Contains($old)) { throw 'Could not find UI culture fallback in Strings.cs.' }
$s = $s.Replace($old, $new)
$old = 'private static string L(string en) => Language == "ar" && Ar.TryGetValue(en, out var ar) ? ar : en;'
$new = @'
private static string L(string en) => Language switch
    {
        "ar" when Ar.TryGetValue(en, out var ar) => ar,
        "zh-CN" when ZhCn.TryGetValue(en, out var zh) => zh,
        _ => en,
    };
'@.TrimEnd()
if (-not $s.Contains($old)) { throw 'Could not find translation lookup method in Strings.cs.' }
$s = $s.Replace($old, $new)
$zh = @'
    private static readonly Dictionary<string, string> ZhCn = new()
    {
        ["Screenshots, hung out to dry."] = "截图，晾在屏幕顶端。",
        ["Show line"] = "显示截图线",
        ["Hide line"] = "隐藏截图线",
        ["Take everything down"] = "收起全部截图",
        ["New capture"] = "新建截图",
        ["Click to take a new screenshot (Win+Shift+S)"] = "点击进行新的屏幕截图（Win+Shift+S）",
        ["Catch clipboard captures"] = "捕获剪贴板截图",
        ["Win+Shift+S and PrtScn captures hang even when no file is saved"] = "即使未保存文件，也会显示通过 Win+Shift+S 和 PrtScn 获取的截图",
        ["Stay down until each capture is used"] = "截图被使用前保持截图线展开",
        ["The line waits while a capture has not been copied, dragged or opened"] = "截图尚未复制、拖动或打开时，截图线会保持展开",
        ["Take down after dragging into an app"] = "拖入应用后收起截图",
        ["A photo dropped into a chat or an app leaves the line, like one saved to a folder"] = "截图拖入聊天窗口或应用后会从截图线上移除，就像保存到文件夹一样",
        ["Bring the line down when the pointer rests at the top edge"] = "鼠标指针停在屏幕顶边时展开截图线",
        ["Hold the pointer still against the top of the screen for half a second. Off, the shortcut and the tray icon show the line."] = "将鼠标指针停在屏幕顶部半秒即可展开。关闭此选项后，可通过快捷键或系统托盘图标显示截图线。",
        ["Open Screenshots folder"] = "打开“屏幕截图”文件夹",
        ["Open caught captures folder"] = "打开捕获截图文件夹",
        ["Sounds"] = "声音",
        ["Start with Windows"] = "随 Windows 启动",
        ["Settings…"] = "设置…",
        ["About Snapline"] = "关于 Snapline",
        ["Quit Snapline"] = "退出 Snapline",
        ["Copy"] = "复制",
        ["Copy text"] = "复制文字",
        ["Open"] = "打开",
        ["Edit"] = "编辑",
        ["Mark up"] = "标注",
        ["Edit in Paint"] = "在画图中编辑",
        ["Pen"] = "画笔",
        ["Highlighter"] = "荧光笔",
        ["Circle"] = "圆形",
        ["Box"] = "矩形",
        ["Arrow"] = "箭头",
        ["Text"] = "文字",
        ["Blur"] = "模糊",
        ["New note"] = "新建便笺",
        ["Menu"] = "菜单",
        ["Edit note"] = "编辑便笺",
        ["Note colour"] = "便笺颜色",
        ["Write a note…"] = "写点内容…",
        ["Yellow"] = "黄色",
        ["Pink"] = "粉色",
        ["Blue"] = "蓝色",
        ["Green"] = "绿色",
        ["Orange"] = "橙色",
        ["Colour"] = "颜色",
        ["Thickness"] = "粗细",
        ["Undo"] = "撤销",
        ["Redo"] = "重做",
        ["Revert to original"] = "还原原图",
        ["Done"] = "完成",
        ["Saved"] = "已保存",
        ["Back to the original"] = "已还原为原图",
        ["Could not save"] = "保存失败",
        ["Show in Explorer"] = "在文件资源管理器中显示",
        ["Keep on the line"] = "固定在截图线上",
        ["Save to Desktop"] = "保存到桌面",
        ["Save to Pictures\\Screenshots"] = "保存到“图片\\屏幕截图”",
        ["Discard"] = "丢弃",
        ["Take down"] = "收起",
        ["Move to Recycle Bin"] = "移至回收站",
        ["Take a screenshot and it will hang here"] = "截取屏幕后，截图会显示在这里",
        ["Copied"] = "已复制",
        ["Text copied"] = "文字已复制",
        ["just now"] = "刚刚",
        ["{0} min ago"] = "{0} 分钟前",
        ["{0} h ago"] = "{0} 小时前",
        ["Settings"] = "设置",
        ["The line"] = "截图线",
        ["Look"] = "外观",
        ["Captures"] = "截图",
        ["General"] = "常规",
        ["Show or hide the line"] = "显示或隐藏截图线",
        ["Click here and press the keys you want, like Ctrl+Alt+T"] = "点击此处并按下所需快捷键，例如 Ctrl+Alt+T",
        ["Distance from the top of the screen"] = "距离屏幕顶部的距离",
        ["You can also drag the line itself up or down"] = "也可以直接上下拖动截图线",
        ["Line colour"] = "截图线颜色",
        ["Clothespins"] = "夹子样式",
        ["Bows at the ends of the line"] = "在截图线两端显示蝴蝶结",
        ["Arrange photos evenly along the line"] = "沿截图线均匀排列截图",
        ["Off, each photo stays where you put it"] = "关闭后，每张截图会停留在放置的位置",
        ["Appearance"] = "主题",
        ["Language"] = "语言",
        ["Follow Windows"] = "跟随 Windows",
        ["Light"] = "浅色",
        ["Dark"] = "深色",
        ["Caught captures are saved to"] = "捕获的截图保存到",
        ["Change…"] = "更改…",
        ["Caught captures need a folder of their own, because discarding one sends it to the Recycle Bin. Pick a folder that is not your Desktop, Pictures, Screenshots or a watched folder, and not a parent of them."] = "捕获的截图需要单独的文件夹，因为丢弃截图会将其移至回收站。请选择一个不是桌面、图片、屏幕截图或受监视文件夹的目录，也不要选择包含这些文件夹的上级目录。",
        ["Folders watched for new screenshots"] = "监视新截图的文件夹",
        ["Add folder…"] = "添加文件夹…",
        ["Remove"] = "移除",
        ["Changes apply right away. Everything lives in {0}."] = "更改会立即生效。所有数据均保存在 {0}。",
        ["Snapline is on the line"] = "Snapline 已就绪",
        ["Take a screenshot and it hangs at the top of the screen. Rest the pointer against the top edge to bring the line down, or press {0}."] = "截取屏幕后，截图会挂在屏幕顶部。将鼠标指针停在屏幕顶边以展开截图线，或按下 {0}。",
        ["Click a photo to copy it. Press and hold to edit it. Double click to open it.\nDrag it along the line to reorder, into an app to send a copy, into a folder to keep it, or to the Recycle Bin to let it go.\nRest the pointer against the top edge of the screen, or press {0}, to bring the line down."] = "单击截图即可复制；按住截图可进行编辑；双击可打开。\n沿截图线拖动可调整顺序；拖入应用可发送副本；拖入文件夹可保存；拖入回收站可丢弃。\n将鼠标指针停在屏幕顶边，或按下 {0}，即可展开截图线。",
        ["Bronze"] = "青铜色",
        ["Gray"] = "灰色",
        ["Black"] = "黑色",
        ["White"] = "白色",
        ["Red"] = "红色",
        ["Gold"] = "金色",
        ["Purple"] = "紫色",
        ["Wooden"] = "木质",
        ["Aluminium"] = "铝制",
        ["Coloured plastic, mixed"] = "混色塑料",
        ["Red plastic"] = "红色塑料",
        ["Blue plastic"] = "蓝色塑料",
        ["Green plastic"] = "绿色塑料",
        ["Yellow plastic"] = "黄色塑料",
    };
'@
$marker = '    private static readonly Dictionary<string, string> Ar = new()'
if (-not $s.Contains($marker)) { throw 'Could not find Arabic translation dictionary in Strings.cs.' }
$s = $s.Replace($marker, $zh + "`r`n" + $marker)
Set-Content -LiteralPath $stringsPath -Value $s -Encoding UTF8

$w = Get-Content -Raw -Encoding UTF8 $settingsWindowPath
$old = 'var language = Choice(new[] { ("auto", Strings.Auto), ("en", "English"), ("ar", "العربية") }, s.Language, v => { s.Language = v; Dispatcher.BeginInvoke(Rebuild); });'
$new = 'var language = Choice(new[] { ("auto", Strings.Auto), ("en", "English"), ("ar", "العربية"), ("zh-CN", "简体中文") }, s.Language, v => { s.Language = v; Dispatcher.BeginInvoke(Rebuild); });'
if (-not $w.Contains($old)) { throw 'Could not find language selector in SettingsWindow.cs; upstream may have changed.' }
$w = $w.Replace($old, $new)
Set-Content -LiteralPath $settingsWindowPath -Value $w -Encoding UTF8

$core = Get-Content -Raw -Encoding UTF8 $settingsPath
$core = $core.Replace('/// <summary>auto, en or ar.</summary>', '/// <summary>auto, en, ar or zh-CN.</summary>')
Set-Content -LiteralPath $settingsPath -Value $core -Encoding UTF8

Write-Host 'Simplified Chinese patch applied.'
