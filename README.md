# eForms Documentation Templates

Generates the eForms Metadata Reference documentation pages from FreeMarker templates and the eForms Metadata Database (MDD).

The generated output is an Antora content module with AsciiDoc pages for codelists, business terms, and business rules.

Published at: https://docs.ted.europa.eu/eforms/latest/reference

## Project structure

```
content/          FreeMarker templates (.adoc.ftl) and static .adoc files
scripts/          Build scripts, Maven POM, Antora playbook
build/            Generated output (gitignored)
```

## Prerequisites

- Java 11+
- Maven 3.8+
- Access to the MDD MySQL database (localhost or remote)
- `mdm-cli` installed in local Maven repository (from the `eforms-metadata-manager` project)

### Installing mdm-cli locally

From the `eforms-metadata-manager/src` directory:

```bash
mvn clean install -pl mdm-cli -am -DskipTests
```

Note the installed version (e.g. `1.29.0-SNAPSHOT`) — you'll need it below.

## Generating documentation pages

### From mdm-cli (preferred)

If you have `eforms-metadata-manager` checked out, you can run the command directly from mdm-cli:

```bash
cd eforms-metadata-manager/src/mdm-cli
mvn exec:java \
  -Dspring.datasource.username=$EFORMS_DATABASE_USERNAME \
  -Dspring.datasource.password=$EFORMS_DATABASE_PASSWORD \
  -Dspring.datasource.url=jdbc:mysql://localhost:3306/TEDEFO_ACC_MDD?allowMultiQueries=true \
  -Dexec.mainClass="eu.europa.ted.mdc.EformsMetadataConverterApplication" \
  -Dexec.args="process-asciidoc --source /path/to/eforms-docs-templates/content --output /path/to/output"
```

### From this project

Using `docs.sh`:

```bash
cd scripts
./docs.sh -u <dbUsername> -s <dbPassword> -e <sdkVersion> process_templates
```

Run `./docs.sh -h` for all available options and actions.

Or using Maven directly:

```bash
cd scripts
mvn -B exec:exec@run-processor \
  -Dmdm.version=1.29.0-SNAPSHOT \
  -Dasciidoc.templates.dir=$(readlink -f ../content) \
  -Dasciidoc.target.dir=$(readlink -f ../build/asciidoc) \
  -Ddb.host=localhost -Ddb.port=3306 -Ddb.name=TEDEFO_ACC_MDD \
  -Ddb.username=$EFORMS_DATABASE_USERNAME -Ddb.password=$EFORMS_DATABASE_PASSWORD \
  -DskipTests
```

Output goes to `build/asciidoc/`.

## Template conventions

- Files named `[selector].adoc.ftl` are bulk templates — one output file is generated per entity (e.g. one per codelist).
- The bracketed name (`codelist_details`, `business_term_details`, etc.) determines the data model passed by mdm-cli.
- Files named `*.adoc.ftl` (without brackets) are single-page templates.
- Plain `.adoc` files are copied as-is to the output.

## Related projects

- **eforms-metadata-manager** — provides `mdm-cli` which processes the templates
- **eforms-docs** — the main docs repo (guides, static pages); the generated output from this project is merged in at build time
