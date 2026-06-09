$files = Get-ChildItem interview-prep -Recurse -Filter "leetcode-*.md" -File
$updated = 0; $skipped = 0
foreach ($f in $files) {
    $content = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
    $eol = if ($content -match "`r`n") { "`r`n" } else { "`n" }

    # 1) Find and remove existing 题目链接 line (with or without leading `>`), anywhere
    $linkRe = [regex]'(?m)^>?\s*题目链接：<(https?://[^>]+)>\s*\r?\n'
    $linkMatch = $linkRe.Match($content)
    if (-not $linkMatch.Success) { Write-Warning ("Link not found: " + $f.Name); $skipped++; continue }
    $url = $linkMatch.Groups[1].Value
    $content = $linkRe.Replace($content, '', 1)

    # 2) Collapse 3+ blank lines into a single blank line
    $content = [regex]::Replace($content, "(?:\r?\n){3,}", $eol + $eol)

    # 3) Find the "## 一、题目" section, then locate the "---" that separates it from "## 二"
    $h1Re = [regex]'(?m)^##\s*一、题目'
    $h1Match = $h1Re.Match($content)
    if (-not $h1Match.Success) { Write-Warning ("Section 一 not found: " + $f.Name); $skipped++; continue }

    # Find the FIRST "\n---\n" after the heading (i.e. the hr that ends 题目 section)
    $hrRe = [regex]'\r?\n---\r?\n'
    $hrMatch = $hrRe.Match($content, $h1Match.Index + $h1Match.Length)
    if (-not $hrMatch.Success) { Write-Warning ("hr after 题目 not found: " + $f.Name); $skipped++; continue }

    # Insert "题目链接：<url>\n\n" right before the hr (the hr already has its leading \n)
    $insertPos = $hrMatch.Index + ($eol).Length    # skip the leading newline of the hr to land at the blank line position
    # Simpler: trim trailing newlines of preceding section, then build cleanly.
    $beforeHr = $content.Substring(0, $hrMatch.Index).TrimEnd("`r","`n"," ","`t")
    $afterHr  = $content.Substring($hrMatch.Index).TrimStart("`r","`n")   # afterHr now starts with "---..."
    $content = $beforeHr + $eol + $eol + "题目链接：<$url>" + $eol + $eol + $afterHr

    Set-Content -LiteralPath $f.FullName -Value $content -Encoding UTF8 -NoNewline
    $updated++
}
"Updated: $updated, Skipped: $skipped"
