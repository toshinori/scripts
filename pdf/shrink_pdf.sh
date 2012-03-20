#!/bin/sh

# use xpdf, pdftk, imagemagick, poppler

set -e

# コマンドライン引数の1番目が対象ファイルのパス
readonly TARGET=$1

# 指定されたファイルが存在しない場合はエラー
if [ ! -e "${TARGET}" ];
then
    echo "${TARGET} not found."
    exit 1
fi

readonly DIR=`dirname "${TARGET}"`
readonly FILENAME=`basename "${TARGET}"`
readonly BASENAME=`basename "${TARGET}" ".pdf"`

# 対象ファイルが存在するディレクトリに移動
echo "Change directory to ${DIR}"
cd "${DIR}"

# 作業ファイル識別するためのプリフィックス
readonly PRIFIX="work"

# 前回処理時に異常終了していた場合に備え
# 作業ファイルを削除
echo "Remove work files."
`rm -rf "${PRIFIX}"`

# コマンドがエラーを返したら自身もエラーを返して終了
if ! [ $? ];
then
	exit 1
fi

# PDFをPPMファイルに変換
echo "Convert PDF to PPM."
readonly RESOLUTION=150
`pdftoppm "${FILENAME}" -r ${RESOLUTION} "${PRIFIX}"`

if ! [ $? ];
then
	exit 1
fi

# PPMファイルをJPGに変換しつつサイズも変更
echo "Convert PPM to JPG."
readonly SIZE=1024
`mogrify -format jpg -geometry ${SIZE}x${SIZE} "${PRIFIX}*.ppm"`

if ! [ $? ];
then
	exit 1
fi

# JPGファイルをPDFに変換
echo "Convert JPG to PDF."
`mogrify -format pdf "${PRIFIX}*.jpg"`

if ! [ $? ];
then
	exit 1
fi

# 元のファイルをバックアップ
echo "Backup base file."
`mv -f "${FILENAME}" "${FILENAME}.bak"`

if ! [ $? ];
then
	exit 1
fi

# 分割されたPDFを結合
echo "Concat PDF."
`pdftk ${PRIFIX}*.pdf output "${FILENAME}"`

if ! [ $? ];
then
	exit 1
fi

# 作業ファイルを削除
echo "Delete work files."
`rm -f *.ppm`
`rm -f *.jpg`
`rm -f ${PRIFIX}*.pdf`

exit 0

