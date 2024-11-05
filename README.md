# projeto_flutter

A new Flutter project with Firebase.

## Getting Started

Este projeto é o ponto de partida para uma aplicação Flutter com integração ao Firebase.

### Pré-requisitos

Certifique-se de ter o [Flutter](https://docs.flutter.dev/get-started/install) e o [Android Studio](https://developer.android.com/studio) instalados.

### Passos para Configuração

1. **Clone o repositório do projeto:**

   ```bash
   git clone https://github.com/seu_usuario/projeto_flutter.git
   cd projeto_flutter


## Instalação das Dependências

No diretório do projeto, execute o comando abaixo para instalar todas as dependências do Flutter e Firebase:

```bash
flutter pub get
```

## Configuração do Firebase

1. Acesse o [Firebase Console](https://console.firebase.google.com/) e crie um novo projeto.
2. Adicione um aplicativo **Android** e/ou **iOS** ao seu projeto Firebase.
3. Baixe o arquivo `google-services.json` (para Android) e adicione-o à pasta `android/app`.
4. Baixe o arquivo `GoogleService-Info.plist` (para iOS) e adicione-o à pasta `ios/Runner`.
5. Configure permissões específicas no iOS, se necessário, editando o arquivo `Info.plist`.

## Executando o Aplicativo no Android Studio

1. Abra o **Android Studio**.
2. Selecione **Open an Existing Project** e escolha o diretório `projeto_flutter`.
3. Conecte um dispositivo físico ou inicie um emulador.
4. No terminal do Android Studio, execute o comando:

```bash
flutter run
```

## Configuração do Firebase Messaging (Notificações Push)

Adicione o pacote `firebase_messaging` no arquivo `pubspec.yaml` para configurar as notificações push:

```yaml
dependencies:
  firebase_messaging: ^14.6.4
```

Para notificações locais, considere o uso do pacote `flutter_local_notifications`.

## Recursos Úteis

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)
- [Documentação do Firebase para Flutter](https://firebase.flutter.dev/)

Para mais detalhes sobre o desenvolvimento com Flutter, consulte a [documentação online](https://flutter.dev/docs), que oferece tutoriais, exemplos práticos e uma referência completa da API.

// esta sendo implementado 
Implementar notificação de mudanças nas listas.
Configurar notificações push no Firebase Cloud Messaging (FCM).