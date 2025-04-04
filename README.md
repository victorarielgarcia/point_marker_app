# CodeFlow Point Marker

Um aplicativo Flutter para marcação de ponto com verificação de localização.

## Funcionalidades

- Marcação de ponto com verificação de localização
- Cadastro de empresas com localização e raio de atuação
- Visualização de registros de ponto por data
- Interface intuitiva e moderna
- Armazenamento local dos dados
- Notificações de sucesso e erro

## Requisitos

- Flutter SDK
- Android Studio / VS Code
- Dispositivo Android ou iOS para testes
- Permissões de localização no dispositivo

## Instalação

1. Clone o repositório
2. Execute `flutter pub get` para instalar as dependências
3. Execute `flutter run` para iniciar o aplicativo

## Uso

1. Na tela "Empresas", cadastre as empresas onde você trabalha:
   - Nome da empresa
   - Endereço
   - Latitude e longitude
   - Raio de atuação em metros

2. Na tela principal:
   - Selecione a empresa onde está marcando o ponto
   - Pressione e segure o botão de digital para marcar entrada
   - Solte o botão para marcar saída

3. Na tela "Registros":
   - Visualize todos os pontos marcados
   - Os registros são organizados por data
   - Cada registro mostra a empresa, horário e tipo (entrada/saída)

## Permissões

O aplicativo requer as seguintes permissões:
- Localização (para verificar se está no local correto)
- Armazenamento (para salvar os dados localmente)
- Notificações (para informar sobre o sucesso ou falha da marcação)

## Desenvolvimento

O aplicativo foi desenvolvido usando:
- Flutter
- Provider para gerenciamento de estado
- Geolocator para acesso à localização
- Path Provider para armazenamento local
- Flutter Local Notifications para notificações

## Contribuição

Sinta-se à vontade para contribuir com o projeto através de pull requests ou reportando issues.
#   p o i n t _ m a r k e r _ a p p  
 