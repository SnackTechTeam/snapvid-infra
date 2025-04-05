# Snap-vid Infraestrutura de microsserviços  

### Tutorial de Implantação através de execução local do terraform

Este tutorial mostra o passo a passo para criar um cluster Kubernetes na AWS e configurar, necessário possuir as aplicações terraform, aws e kubectl instaladas e configuradas.

---

#### **1. Criar o Cluster e os Nós com o Terraform**

**a) Inicializar o Terraform**
Inicie o Terraform no diretório do projeto para baixar os provedores e configurar o backend remoto. O parametro "bucket" do comando abaixo deve ser substituido pelo nome de um bucket previamente criado no S3 da sua conta.

```bash
terraform init -backend-config="bucket=snapvid-tfstate" -backend-config="key=microsservices/terraform.tfstate" -backend-config="region=us-east-1"

```

**b) Validar a Configuração**
Verifique se há erros na configuração do Terraform.

```bash
terraform validate
```

**c) Gerar o Plano de Execução**
Antes de aplicar as mudanças, gere um plano detalhado para visualizar o que será criado ou modificado. Neste comando substituia NNNNNNNNNNNN pelo valor de um role-id válido. Esse id pode se obtido na página do IAM, dentro do role voclabs da conta LAB da AWS Academy.

```bash
terraform plan -out=tfplan -var accountIdVoclabs=NNNNNNNNNNNN
```

**d) Visualizar o Plano de Execução**
Exiba o conteúdo do plano gerado.

```bash
terraform show tfplan
```

**e) Aplicar o Plano**
Provisione os recursos na AWS. Confirme a execução ou use a flag `-auto-approve` para pular a confirmação.

```bash
terraform apply tfplan
```

**f) Verificar a Criação do Cluster**
Após a execução do Terraform, verifique se o cluster foi criado corretamente com o comando:

```bash
aws eks describe-cluster --name snapvid-infra --region us-east-1
```

**g) Configurar o Acesso ao Cluster com `kubectl`**
Atualize a configuração do Kubernetes para acessar o cluster criado.

```bash
aws eks update-kubeconfig --name snapvid-infra --region us-east-1
```

**h) Verificar os Nós**
Verifique se os nós do cluster estão ativos.

```bash
kubectl get nodes
```
**h) Destruir a infra criada**
- Apague manualmente todas as imagens armazenadas dentro dos ECRs
- Rode o comando abaixo com o mesmo numero de role-id usado no comando plan

```bash
terraform destroy -var accountIdVoclabs=NNNNNNNNNNNNN
```

#### **2. Ajustar configuração do pipeline para deploy usando Github Action**
O procedimento abaixo diz respeito a atualização de variables e secrets do Team. Não sobrescreva os valores incluidos no Team através de parametros especificos do repositório, isso vai causar problemas durante um deploy conjunto. 

**a) Ajustar credenciais AWS**
A cada nova execução do pipeline os valores das credenciais devem ser atualizados. Esses valores devem ser incluídos noos secrets de nome:
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_SECRET_ACCESS_TOKEN
- AWS_ACCOUNT_ID_VOCLABS (número do role-id do voclabs, obtido na página do IAM)

**b) Ajustar bucket do tf-state**
Sempre que ocorrer troca da conta destino do deploy trocar o valor da variável **BACKEND_BUCKET_NAME**, o valor deve corresponder a um bucket S3 previamente criado na conta do deploy.

**c) Ajustar parametros de banco de dados**
A troca da conta destino do deploy, vai gerar instancias de banco de dados com endereços diferentes. Ou seja, após o deploy atualize manualmente os secrets que contém CONNECTION_STRING.

## CI/CD

Este repositório possui um pipeline configurado para executar análise de vulnerabilidades com Sonarqube e o deploy da infraestrutura. 
Como resultado de um PR aprovado para a branch main, é desencadeado o processo de deploy para uma conta AWS previamente configurada nas variáveis de ambiente.

## Equipe

* Adriano de Melo Costa. Email: adriano.dmcosta@gmail.com
* Rafael Duarte Gervásio da Silva. Email: rafael.dgs.1993@gmail.com
* Guilherme Felipe de Souza. Email: gui240799@outlook.com
* Dayvid Ribeiro Correia. Email: dayvidrc@gmail.com
