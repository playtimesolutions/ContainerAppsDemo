using Azure.Extensions.AspNetCore.Configuration.Secrets;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

namespace DotnetApi;

public static class Extensions
{
    public static IConfigurationBuilder AddKeyVaultSecrets(this IConfigurationBuilder builder, string prefix)
    {
        var settings = builder.Build();

        var environment = settings["ASPNETCORE_ENVIRONMENT"];
        if (environment == "Azure")
        {
            var keyVaultEndpoint = settings["AzureKeyVaultUri"];
            var azureADManagedIdentityClientId = settings["AzureADManagedIdentityClientId"];
        
            var credentials = new DefaultAzureCredential(new DefaultAzureCredentialOptions
            {
                ManagedIdentityClientId = azureADManagedIdentityClientId
            });
        
            builder.AddAzureKeyVault(new Uri(keyVaultEndpoint), credentials,
                new AzureKeyVaultConfigurationOptions
                {
                    Manager = new PrefixKeyVaultSecretManager(prefix)
                });
        }
        
        return builder;
    }

    private class PrefixKeyVaultSecretManager : KeyVaultSecretManager
    {
        private readonly string _prefix;

        public PrefixKeyVaultSecretManager(string prefix) => _prefix = $"{prefix}-";

        public override bool Load(SecretProperties properties) => properties.Name.StartsWith(_prefix);

        public override string GetKey(KeyVaultSecret secret) 
            => secret.Name[_prefix.Length..].Replace("--", ConfigurationPath.KeyDelimiter);
    }
}