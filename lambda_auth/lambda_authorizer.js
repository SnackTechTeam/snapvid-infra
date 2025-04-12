// Importar a biblioteca
const { CognitoJwtVerifier } = require("aws-jwt-verify");

// --- Variáveis de Ambiente ---
// Certifique-se de que estas estão definidas no seu Terraform
const COGNITO_USERPOOL_ID = process.env.COGNITO_USERPOOL_ID;
const COGNITO_REGION = process.env.COGNITO_REGION;
const COGNITO_APP_CLIENT_ID = process.env.COGNITO_APP_CLIENT_ID; // Adicionaremos esta no TF

// --- Verificador JWT ---
// Criar o verificador fora do handler para reutilização (melhora performance)
// Verifique se as variáveis de ambiente existem antes de criar o verificador
let verifier;
if (COGNITO_USERPOOL_ID && COGNITO_REGION && COGNITO_APP_CLIENT_ID) {
    verifier = CognitoJwtVerifier.create({
        userPoolId: COGNITO_USERPOOL_ID,
        tokenUse: "id", // Ou "id" dependendo do token que você espera (Access Token é comum para APIs)
        clientId: COGNITO_APP_CLIENT_ID,
        // scope: "read", // Descomente e ajuste se precisar validar escopos específicos
    });
    console.log("Cognito JWT Verifier configured.");
} else {
    console.error("Missing required environment variables for Cognito JWT Verifier!");
}


exports.handler = async (event) => {
    console.log("Event received:", JSON.stringify(event, null, 2));

    // 1. Extrai o token do header
    const authHeader = event.authorizationToken || event.headers?.Authorization;
    if (!authHeader) {
        console.error("Missing Authorization header");
        return generatePolicy('anonymous', 'Deny', event.methodArn || "*");
    }

    // 2. Remove 'Bearer ' se existir
    const token = authHeader.replace(/^Bearer\s+/i, '');
    console.log("Token extracted:", token.slice(0, 10) + "..."); // Log parcial por segurança

    // Verificar se o verifier foi inicializado corretamente
    if (!verifier) {
        console.error("Cognito JWT Verifier is not initialized due to missing environment variables.");
        return generatePolicy('error', 'Deny', event.methodArn || "*");
    }
    
    try {
        // 3. Verifica o token JWT usando a biblioteca
        console.log("Verifying token...");
        const payload = await verifier.verify(token);
        console.log("Token is valid. Payload:", payload);
        
        // 4. Retorna política ALLOW para QUALQUER recurso/método da API
        return {
            principalId: payload.sub || "unknown",
            policyDocument: {
                Version: "2012-10-17",
                Statement: [{
                    Action: "execute-api:Invoke",
                    Effect: "Allow",
                    Resource: "*" // Permite acesso a qualquer recurso/método desta API
                }]
            },
            context: {
                userId: payload.sub,
                email: payload.email || ""
            }
        };

    } catch (error) {
        console.error("Token verification failed:", error);
        // O erro pode ser por token inválido, expirado, assinatura incorreta, etc.
        return generatePolicy('invalid_token', 'Deny', event.methodArn || "*");
    }
};

function generatePolicy(principalId, effect, resource) {
    console.log(`Generating ${effect} policy for ${principalId}`);
    return {
        principalId,
        policyDocument: {
            Version: "2012-10-17",
            Statement: [{
                Action: "execute-api:Invoke",
                Effect: effect,
                Resource: resource
            }]
        }
    };
}