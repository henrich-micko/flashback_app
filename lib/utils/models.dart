// abstract class for all models
// TODO: change the throw to something smarter

abstract class BaseModel {
  BaseModel();
  BaseModel.fromJson(Map<String, dynamic> json);
}