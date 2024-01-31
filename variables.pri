PROJECT_DIR=$$PWD

schema_name=\\\"test_cim\\\"
DEFINES += DB_SCHEMA_NAME=$${schema_name}
message(schema_name: $$DB_SCHEMA_NAME)
