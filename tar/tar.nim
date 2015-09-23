import strutils
import parseutils
import os


proc untar*(filename: string, destdir: string): bool =
    result = true
    let file = open(filename)
    var emptyar: array[512,uint8]

    var emptyblocks = 0
    while true:
        if emptyblocks == 2:
            echo "finished"
            break

        var buf : array[512,uint8]

        var num_of_bytes = file.readBytes(buf,0,512)
        
        if buf==emptyar:
            emptyblocks += 1
            continue

        var name = '\0'.repeat(100)
        var size = '\0'.repeat(13)

        copyMem(addr(name[0]),addr(buf[0]),100)
        copyMem(addr(size[0]),addr(buf[124]),12)
        if name == "":
            break;
        echo name
        if buf[156].char == '5':
            createDir(destdir & name)

        var sizei = parseOctInt(size)
        var steps :int
        steps = sizei div 512
        if (sizei mod 512)>0:
            steps+=1
        if buf[156].char == '0' or buf[156].char=='\0':
            let file_out = open(destdir & name,fmWrite)
            block write_file_block:
                for i in 1..steps:
                    var a:array[512,uint8]
                    var nums = file.readBytes(a,0,512)
                    for c in a:
                        file_out.write(c.char)
                        sizei-=1
                        if sizei==0:
                            break write_file_block
            close(file_out)
        else:
            for i in 1..steps:
                var a:array[512,uint8]
                var nums = file.readBytes(a,0,512)
