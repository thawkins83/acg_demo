#! /bin/bash

code_path="$(dirname $0)"
echo $code_path
archives="$code_path/archives"
mkdir -p $archives

cd "$code_path/lambda"
zip ../archives/lambda.zip *
cd ..

