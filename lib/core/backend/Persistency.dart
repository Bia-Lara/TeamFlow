abstract class Persistency<F, K> {
  Future<F> register(F entity);

  Future<F> update(F entity);

  void delete(K key);

  Future<F> getById(K entity);

  Future<List<F>> getByStringColumn(String columnName, String? value);
}