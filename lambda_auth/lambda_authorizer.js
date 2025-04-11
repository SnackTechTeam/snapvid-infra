exports.handler = async (event) => {
    console.log("Event received:", JSON.stringify(event, null, 2));
    
    try {
        // 1. Extrai o token do header
        const authHeader = event.authorizationToken || event.headers?.Authorization;
        if (!authHeader) {
            console.error("Missing Authorization header");
            return generatePolicy('anonymous', 'Deny', event.methodArn);
        }

        // 2. Remove 'Bearer ' se existir
        const token = authHeader.replace(/^Bearer\s+/i, '');
        console.log("Token extracted:", token.slice(0, 10) + "..."); // Log parcial por segurança

        // 3. Decodifica o payload JWT (sem verificar assinatura)
        const payload = JSON.parse(Buffer.from(token.split('.')[1], 'base64').toString());
        console.log("Decoded payload:", payload);

        // 4. Retorna política ALLOW
        return {
            principalId: payload.sub || "unknown",
            policyDocument: {
                Version: "2012-10-17",
                Statement: [{
                    Action: "execute-api:Invoke",
                    Effect: "Allow",
                    Resource: event.methodArn || "*" // Fallback importante
                }]
            },
            context: {
                userId: payload.sub,
                email: payload.email || ""
            }
        };

    } catch (error) {
        console.error("Authorizer error:", error);
        return generatePolicy('anonymous', 'Deny', event.methodArn || "*");
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