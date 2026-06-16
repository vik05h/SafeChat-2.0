import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../domain/models/auth_models.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  @GET("/api/v1/auth/me")
  Future<HttpResponse<AuthMeResponse>> getMe();

  @POST("/api/v1/auth/onboard")
  Future<HttpResponse<dynamic>> onboard(@Body() OnboardRequest request);
}
