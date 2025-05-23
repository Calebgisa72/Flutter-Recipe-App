
import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> serverToken() async {
    final scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson({
        "type": "service_account",
        "project_id": "flutter-recipe-app-6b63e",
        "private_key_id": "1bff76a7a4e77c6cffb7315bb48f9d94af2b3e29",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDc81P/XaR0ugNa\nx1p55Lf77aXHYTbBNUVRgAdi3V5erzbLtKctjgcvMDRO7fOfK7SbMZYfcyLfN7a0\nMdd8ktYsNwnMv9RrW3yz81HFH2dNThbGTsjrcjIgGWJnur+OWdGsiTJSYhnA6Jfe\nVQok5btuowjIsJ5FxdsE9+aNHfhKBru2FSqXvPNPVgmrHJw8zpxWazPfEYZbi7ax\nNY8+J10Kl/qc+79qSfU7C/Tb3+duH9BYamDw36338GdCNmprotPytfuN9eK+cygm\nJu25A1B13Yu/Ji0kiThmRSM8UVZLWy6AzOdyBLzY0k7/R+bU5rnTZRbZnmAJ1qpJ\noYyr1QWtAgMBAAECggEABpBoD28dwqYAEYNYqcRkvuRJh4nY0Zaej5RJI+PFuPRl\noVmlmdHdXsaE1090bGck/3NSrW6DO7RxBhtw9m96U2fzL5UHX4UhSEtTQ5LyQ7at\nMIkIqQ4EdTWr2b8Pj9AVTZXp2860Synd0SofmgcFMX1Ado3gtdvx7MzcmZapWLGa\nYaGcPnkDoFPogVvhu0aio915s1JEyoGCf6kfAsUeukIC1XO1WbP5EGkJPFxxu5Y9\nqdrf35aJOEfzJie9cIccrMkJVFP0LsMfdDlMOp/+oDdtrECMRo+B0wqAQxeX0EbJ\nWrQ/t/VTsG0v/0PXSWPwieTXSbCcLpKDZ+afLaoBoQKBgQDyzLutmpA9d+z/U8KH\noaxo2fCEqA1m/pQKkJjTGaAnDQyA4q8w6dHvzmiyzLfGJugBUt+/A6wDurAu58Bq\nsTmkhgSZkdpBI/cIxWOOyZaS4UMiIudxXbwsfusxGiWlSIJbX4W8rpyluxUWFlrm\nr1HJr/luFK3o9LlWMKK4YWJ2NQKBgQDo9n/EPhgN5BgRZ//ezuPjelw8uAGcCjlp\n9+bvb5apHvnpCLlR9wZzCCunYaO2gkIIEsAur3tZZoO/HGo3999+l3aYG8Inn5KT\n9YEst+iygg6HGtXfAAZ0XJe0IFlUM0kpMA5xFIbFwoFXWtAAYR1L77KBYrvjZs5w\n1peaiBbgmQKBgHfUtbf7tb6wpqZpV3QLRgVFsuA19M9lS/le3h4p4pIDba1as65H\naFabn67HPNguMYkdttIWZNo+VGAB/0RpDZL2leSZSIen0W9hxD4fnhIF3VVGtsWL\nxqiLR1anmfbWL4gbP+0cnLFrAQAyrlB2LL6G/GrpB+AWkDZKsLShU7AVAoGBAKx4\nKdkYe2h1UJg6XYUPuElmAjl1pMNoEl9wh8kF3Q1yAGTU75ZOArlQ+DigIbrxrn8Z\nmqw1gGWMbsci+0RaP10SN1ufWVtKWRMvM6XutdjKToUZifLhquWk0y8or9mVanmS\nuW5gWvK38FfCxLEzNKROXeJKPX26U+XYCT7/t6gpAoGAbB2ucf74ynannOC0xb2l\nInTHUvOv/LcDoLM2ZEMR/PHVw/bkn/fl1Q+EXCwSTXiVad5QOpvr9548NOucxo2f\ntUymQDJAL4Nbe99E2gpwtFH2llO2imDLuAr3uwDjkKqLSfCcBUl/b8mTvzV/uvSh\ncA26r+IjGy/QkmGhT3hufiY=\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-fbsvc@flutter-recipe-app-6b63e.iam.gserviceaccount.com",
        "client_id": "101233069625148982096",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40flutter-recipe-app-6b63e.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com",
      }),
      scopes,
    );
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}
