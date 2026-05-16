import { Monaco } from '@monaco-editor/react'
import { consola } from 'consola/browser'
import axios from 'axios'

export const MonacoSetupFeature = {
    setup: async (monaco: Monaco) => {
        try {
            const response = await axios.get('xray.schema.json')
            const schema = response.data

            if (
                !schema ||
                typeof schema !== 'object' ||
                !('definitions' in schema) ||
                typeof (schema as { definitions?: unknown }).definitions !== 'object'
            ) {
                consola.error(
                    'Invalid xray.schema.json: expected JSON Schema with definitions. Rebuild: make -f Makefile.windows schema'
                )
                return
            }

            monaco.languages.json.jsonDefaults.setDiagnosticsOptions({
                allowComments: true,
                enableSchemaRequest: true,
                schemaRequest: 'warning',
                schemas: [
                    {
                        fileMatch: ['*'],
                        schema,
                        uri: 'https://xray-config-schema.json'
                    }
                ],
                validate: true
            })
        } catch (error) {
            consola.error('Failed to load JSON schema:', error)
        }
    }
}
