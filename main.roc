# Run with `roc ./examples/CommandLineArgsFile/main.roc -- examples/CommandLineArgsFile/input.txt`
app [main!] {
    cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.20.0/X73hGh05nNTkDHU06FHC0YfFaQB1pimX7gncRcao5mU.tar.br",
}

import cli.Stdout
import cli.File
import cli.Arg exposing [Arg]

main =
    task =
        # Get source and destination directories from command line args
        args <- Env.args |> Task.await
        
        when args is
            [_, sourceDir, destDir] ->
                processImages sourceDir destDir
            
            _ ->
                Stderr.line "Usage: roc run main.roc -- <source-directory> <destination-directory>"
    
    Task.attempt task \result ->
        when result is
            Ok {} -> Stdout.line "Successfully moved all images!"
            Err err -> Stderr.line "Error: $(Inspect.toStr err)"

processImages : Str, Str -> Task {} _
processImages = \sourceStr, destStr ->
    sourcePath = Path.fromStr sourceStr
    destPath = Path.fromStr destStr
    
    # Create destination directory if it doesn't exist
    _ <- Dir.create destPath |> Task.await
    
    # List all files in source directory
    entries <- Dir.list sourcePath |> Task.await
    
    # Filter for image files
    imageFiles = List.keepIf entries isImageFile
    
    # Copy and delete each image
    Stdout.line! "Found $(Num.toStr (List.len imageFiles)) image(s)"
    
    List.walkTry imageFiles {} \{}, imagePath ->
        moveImage sourcePath destPath imagePath

isImageFile : Path -> Bool
isImageFile = \path ->
    pathStr = Path.display path
    
    List.any [".jpg", ".jpeg", ".png", ".gif", ".webp", ".heic", ".JPG", ".JPEG", ".PNG"] \ext ->
        Str.endsWith pathStr ext

moveImage : Path, Path, Path -> Task {} _
moveImage = \sourceDir, destDir, imagePath ->
    # Get just the filename
    filename = Path.display imagePath |> extractFilename
    
    # Build full paths
    sourcePath = Path.append sourceDir filename
    destPath = Path.append destDir filename
    
    # Copy the file
    Stdout.line! "Copying $(filename)..."
    bytes <- File.readBytes sourcePath |> Task.await
    _ <- File.writeBytes destPath bytes |> Task.await
    
    # Delete the original
    Stdout.line! "Deleting original $(filename)..."
    File.delete sourcePath

extractFilename : Str -> Str
extractFilename = \pathStr ->
    when Str.splitLast pathStr "/" is
        Ok { after } -> after
        Err NotFound -> pathStr
