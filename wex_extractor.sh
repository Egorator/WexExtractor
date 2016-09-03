#!/bin/bash

# Install required packages (if necessary):
# sudo apt-get install zip p7zip-full file findutils grep coreutils

usage()
{
	echo "Usage: $(basename $0) INPUT_FILE.wex" 1>&2
	exit 1
}

if [ $# -ne 1 ]; then
	usage
fi
WEX_FILE="$1"

if [ ! -f "$WEX_FILE" ]; then
	echo "File not found: \"$WEX_FILE\"." 1>&2
	exit 2
fi

# Exit on first error:
set -e

FILE_NAME_NO_EXTENSION="$(echo ${WEX_FILE} | cut -d'.' -f1)"
OUT_DIR="$FILE_NAME_NO_EXTENSION"
ZIP_ARCHIVE="${FILE_NAME_NO_EXTENSION}.zip"

# Delete previous results if any:
rm -rf "${OUT_DIR}" "${ZIP_ARCHIVE}"

# Treat ${WEX_FILE} as zip arcive and try to fix it:
zip -FF "${WEX_FILE}" --out "${ZIP_ARCHIVE}"

# Zip archive we've got contains some files.
# All files have the same name: "...hs4tda."
# We need to extract them all and use different output file names.
# 7za asks what to do if file already exists on file system.
# We answer "u", which means "aUtomatically rename files".

# Extract all files from zip archive to ${OUT_DIR} and automatically rename files:
echo 'u' | 7za x "${ZIP_ARCHIVE}" -o"${OUT_DIR}"

# Delete zip archive:
rm "${ZIP_ARCHIVE}"

# Loop through extracted files and rename them:
cd "${OUT_DIR}"
EXTRACTED_FILES="$(find -type f)"
FILE_NUMBER=0
set +e
for extracted_file in ${EXTRACTED_FILES} ; do
	((FILE_NUMBER++))
	NEW_FILE_NAME="$(printf '%03d' ${FILE_NUMBER})"

	# Delete empty files:
	FILE_SIZE=$(du -b "${extracted_file}" | cut -f1)
	if [ $FILE_SIZE -eq 0 ]; then
		rm "${extracted_file}"
		continue
	fi

	# Rename html:
	if file "${extracted_file}" | grep -q "HTML document" ; then
		if head -n1 "${extracted_file}" | grep -q 'DOCTYPE HTML PUBLIC' ; then
			mv "${extracted_file}" "dummy.html"
			continue
		fi

		mv "${extracted_file}" "index.html"
		continue
	fi

	# Rename png:
	if file "${extracted_file}" | grep -q "PNG image data" ; then
		mv "${extracted_file}" "${NEW_FILE_NAME}.png"
		continue
	fi

	# Rename jpeg:
	if file "${extracted_file}" | grep -q "JPEG image data" ; then
		mv "${extracted_file}" "${NEW_FILE_NAME}.jpg"
		continue
	fi
done

