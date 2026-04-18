@echo off
REM Gera modelos Dart a partir do contrato OpenAPI da API LumiLivre.
REM Pré-requisito: openapi-generator-cli instalado (npm i -g @openapitools/openapi-generator-cli)

SET API_URL=%API_URL%
IF "%API_URL%"=="" SET API_URL=https://lumilivre-api.onrender.com

SET SPEC_URL=%API_URL%/v3/api-docs
SET OUTPUT_DIR=lib\api\gen

echo Baixando spec de: %SPEC_URL%
curl -fsSL "%SPEC_URL%" -o "%TEMP%\lumilivre-api-docs.json"

echo Gerando modelos Dart em: %OUTPUT_DIR%
openapi-generator-cli generate ^
  -i "%TEMP%\lumilivre-api-docs.json" ^
  -g dart-dio ^
  -o "%OUTPUT_DIR%" ^
  --additional-properties=pubName=lumilivre_api,pubAuthor=LumiLivre,nullableFields=true ^
  --global-property=models,supportingFiles ^
  --skip-validate-spec

echo Formatando codigo gerado...
dart format "%OUTPUT_DIR%"

echo Codegen concluido. Arquivos em: %OUTPUT_DIR%
