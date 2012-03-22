#!/bin/sh

set -e

# 対象ディレクトリと基準日をコマンドライン引数から取得
readonly TARGET=$1
readonly BASE_DATE=$2

# 比較に使用する一時ファイルを作成
readonly TMP_START="start"

# 作成日が指定された日のファイルを作成
COMMAND="touch -mt  ${BASE_DATE}0000 ./${TMP_START}"
`${COMMAND}`

if [ $? -ne 0  ];
then
        echo 'Error happend.'
        exit 1
fi

# 上記で作成したファイルよりも新しいファイルを検索
`find "${TARGET}" -type f -newer ./${TMP_START} 1>&2`

# 後片付け
`rm -f ./${TMP_START}`

