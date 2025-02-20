import 'package:flashbacks/utils/api/client.dart';
import 'package:flashbacks/utils/models.dart';

// objects

mixin ApiModelAllMixin<T extends BaseModel> on BaseApiModelClient<T> {
  Future<Iterable<T>> all() async {
    return getItems<T>(modelPath, itemFromJson);
  }
}

mixin ApiModelGetMixin<T extends BaseModel> on BaseApiModelClient<T> {
  Future<T> get(int pk) async {
    return getItem<T>(modelPath, itemFromJson);
  }
}

mixin ApiModelFilterMixin<T extends BaseModel> on BaseApiModelClient<T> {
  Future<Iterable<T>> filter(Map<String, String> params) async {
    return getItems<T>(modelPath, itemFromJson, filter: params);
  }
}

mixin ApiModelDeleteMixin<T extends BaseModel> on BaseApiModelClient<T> {
  Future delete(int pk) async {
    return deleteItem(modelPath);
  }
}

mixin ApiModelSearchMixin<T extends BaseModel> on BaseApiModelClient<T> {
  Future<Iterable<T>> search(String query, {String path="search/"}) async {
    return getItems<T>("$modelPath$path", itemFromJson, filter: {"q": query});
  }
}

// detail

mixin ApiDetModelDeleteMixin<T extends BaseModel> on BaseApiModelDetailClient<T> {
  Future delete() async {
    return deleteItem(modelPath);
  }
}

mixin ApiDetModelGetMixin<T extends BaseModel> on BaseApiModelDetailClient<T> {
  Future<T> get() async {
    return getItem(modelPath, itemFromJson);
  }
}

mixin ApiDetModelPatchMixin<T extends BaseModel> on BaseApiModelDetailClient<T> {
  Future<T> patch(JsonData data) async {
    return patchItem<T>(modelPath, data, itemFromJson);
  }
}
