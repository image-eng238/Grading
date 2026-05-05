#!/bin/bash

# data/ 配下の C ソースファイルを gcc で全てビルド
# ビルドしたファイルを実行 パイプで同じ入力を渡して，出力結果を記録

# 実行ファイル名
# ビルドできたかどうか
# ビルドできてたら標準出力をリダイレクト

# 引数
# -p <入力> それぞれのプログラムでテストする標準入力
# -a <引数> それぞれのプログラムに渡す引数
# -f <ファイル名> 結果を出力するファイル

function help() {
    echo -e "渡されたzipファイル内のソースコードをビルドして標準出力をファイルに保存"
    echo -e "-a, --argument <引数> テストするプログラムに渡す引数"
    echo -e "-f, --file <ファイル名> 結果を保存するファイル"
    echo -e "-h, --help ヘルプを表示して終了"
    echo -e "-p, --pipeline <入力> テストするプログラムでに渡す標準入力"
    echo -e "-z, --zip <zipファイル> テストするソースコードが保存されているzipファイル"
}

function timeout() {
    (shift;$@) &
    {
        set -- "$1" $!
        (sleep "$1"; kill -s TERM "$2"; exit 124)&
        wait "$2"
        pre="$?"
        kill -s KILL $!
        wait $!
        return $pre
    } 2> /dev/null
}

function execute() {
    echo -e "実行中..."
    echo -e "$pipe" | ./bin/$bin_file $argument > $tmp_file
    cat $tmp_file >> $out_file
}

argument=""
pipe=""
out_file="./log/result.log"
zip_file=""
tmp_file=$(mktemp /tmp/exe-XXX.txt||echo テンポラリファイルの作成に失敗しました;exit 1)
trap "rm -f ${tmp_file}" EXIT

# 引数の処理
while [ "$#" -gt 0 ]; do
    case "${1}" in
        -a | --argument)
            shift
            argument="${1}"
        ;;
        -h | --help)
            help
            exit
        ;;
        -f | --file)
            shift
            out_file="./log/${1}"
        ;;
        -p | --pipeline)
            shift
            pipe="${1}"
        ;;
        -z | --zip)
            shift
            zip_file="${1}"
        ;;
        *)
            echo -e "\"${1}\" 不明な引数です"
            exit
        ;;
    esac
    shift
done

# 使用するディレクトリの作成
if [ ! -d bin ]; then
    mkdir bin
fi
if [ ! -d data ]; then
    mkdir data
fi
if [! -d log ]; then
    mkdir log
fi

# zipファイルを解凍
if [ -n "${zip_file}" ]; then
    unzip -O sjis -o ./data/"${zip_file}" -d "./data/"
    if [ ${?} ]; then
        echo -e "zipファイルの解凍に失敗しました"
        exit 1
    fi
fi

c_source_files=($(ls ./data/ | grep -x '.*\.c'))

echo -e "引数: \"$argument\"\n標準入力: \"$pipe\"\n" | tee $out_file

# ビルドとテスト
for s_file in "${c_source_files[@]}"; do
    echo "$s_file をビルド中..."
    echo "> $s_file" >> $out_file

    bin_file=$(echo $s_file | sed 's/.c//')

    if gcc -g ./data/$s_file -o ./bin/$bin_file; then
        echo "> ビルド成功" | tee -a $out_file
        if [ "$pipe" ]; then
            # 標準入力を渡す場合，タイムアウトを指定
            echo -e "" >> $out_file
            if timeout 1 execute; then
                echo -e "" >> $out_file
            else
                echo -e "実行時間が長すぎるため，手動でテストしてください\n" >> $out_file
            fi
            echo -e "> 終了"
        else
            # 標準入力を指定しない場合，scriptコマンドで手動で入力できるようにする
            script -a -q -B $out_file -c "./bin/$bin_file $argument"
            echo -e "> 終了"
        fi
    else
        echo "> ビルド失敗" | tee -a $out_file
    fi

   echo -e ""
done

echo -e "出力結果: $out_file"
