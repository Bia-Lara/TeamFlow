import 'user.entity.dart';

User getMockUser() {
  return User(
    id: '1',
    name: 'João Dias',
    email: 'joao.dias@email.com',
    password: '123456',
    groupIds: ['1', '2', '3'],
  );
}
