#!/usr/bin/env bash
# Gera modelos Dart a partir do contrato OpenAPI da API LumiLivre.
# Pré-requisito: openapi-generator-cli instalado (npm i -g @openapitools/openapi-generator-cli)
#
# Uso:
#   ./scripts/generate_api.sh                         # usa API em prod
#   API_URL=http://localhost:8080 ./scripts/generate_api.sh

set -euo pipefail

API_URL="${API_URL:-https://lumilivre-api.onrender.com}"
SPEC_URL="${API_URL}/v3/api-docs"
OUTPUT_DIR="lib/api/gen"

echo "Baixando spec de: ${SPEC_URL}"
curl -fsSL "${SPEC_URL}" -o /tmp/lumilivre-api-docs.json

echo "Gerando modelos Dart em: ${OUTPUT_DIR}"
openapi-generator-cli generate \
  -i /tmp/lumilivre-api-docs.json \
  -g dart-dio \
  -o "${OUTPUT_DIR}" \
  --additional-properties=pubName=lumilivre_api,pubAuthor=LumiLivre,nullableFields=true \
  --global-property=models,supportingFiles \
  --skip-validate-spec

echo "Formatando código gerado..."
dart format "${OUTPUT_DIR}" || true

echo "Codegen concluído. Arquivos em: ${OUTPUT_DIR}"
