# mihoyoGameScreenShotUidCropper.ps1
# FFmpeg: 2021-03-09-git-c35e456f54-full_build-www.gyan.dev

$path = $PSCommandPath | Split-Path -Parent

$extensionArray = "jpg", "png"

foreach ($extension in $extensionArray)
{
    foreach ($file in Get-ChildItem -Path $path -Filter "*.$extension")
    {
        # 이미 _fixed 처리된 파일은 건너뜀
        if ($file.BaseName -like "*_fixed*") { continue }

        $inputFile = $file.FullName

        Write-Output "Checking: $($file.Name)"

        # 현재 해상도 확인
        $width, $height = ffprobe -v error `
            -select_streams v:0 `
            -show_entries stream=width,height `
            -of default=nw=1:nk=1 `
            "$inputFile"

        # 3840x2160이 아니면 완전히 skip
        if ($width -ne 3840 -or $height -ne 2160)
        {
            Write-Output "Skipped (not 3840x2160): $($file.Name)"
            continue
        }

        Write-Output "Working: $($file.Name)"

        # 아래 72px 크롭 후 _fixed 파일 생성
        $fixedFile = Join-Path $path ($file.BaseName + "_fixed" + $file.Extension)

        if ($extension -eq "png")
        {
            ffmpeg -hide_banner -loglevel error -y `
                -i "$inputFile" `
                -vf "crop=3840:2088:0:0" `
                -frames:v 1 `
                "$fixedFile"
        }
        else
        {
            ffmpeg -hide_banner -loglevel error -y `
                -i "$inputFile" `
                -vf "crop=3840:2088:0:0" `
                -frames:v 1 `
                -q:v 1 `
                "$fixedFile"
        }
    }
}

Write-Output "Done."