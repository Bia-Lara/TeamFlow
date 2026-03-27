import '../domain/task.dart';

List<Task> getMockTasks() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final yesterday = today.subtract(const Duration(days: 1));

  return [
    Task(
      id: '1',
      userId: '1',
      title: 'Criar wireframes do app',
      description: 'Criar wireframes de todas as telas principais do aplicativo',
      groupId: '1',
      groupName: 'Design',
      dueDate: today.add(const Duration(hours: 9)),
      priority: TaskPriority.alta,
      isCompleted: false,
    ),
    Task(
      id: '2',
      userId: '1',
      title: 'Reunião com o time',
      description: 'Alinhamento semanal sobre o progresso do projeto',
      groupId: '3',
      groupName: 'Geral',
      dueDate: today.add(const Duration(hours: 14)),
      priority: TaskPriority.media,
      isCompleted: false,
    ),
    Task(
      id: '3',
      userId: '1',
      title: 'Revisar pull requests',
      description: 'Revisar PRs pendentes no repositório principal',
      groupId: '2',
      groupName: 'Dev',
      dueDate: today.add(const Duration(hours: 16, minutes: 30)),
      priority: TaskPriority.alta,
      isCompleted: false,
    ),
    Task(
      id: '4',
      userId: '1',
      title: 'Entregar protótipo final',
      description: 'Finalizar e entregar o protótipo para aprovação do cliente',
      groupId: '1',
      groupName: 'Design',
      dueDate: tomorrow.add(const Duration(hours: 10)),
      priority: TaskPriority.alta,
      isCompleted: false,
    ),
    Task(
      id: '5',
      userId: '1',
      title: 'Atualizar documentação',
      description: 'Atualizar a documentação técnica do projeto',
      groupId: '2',
      groupName: 'Dev',
      dueDate: tomorrow.add(const Duration(hours: 15)),
      priority: TaskPriority.baixa,
      isCompleted: false,
    ),
    Task(
      id: '6',
      userId: '1',
      title: 'Configurar CI/CD',
      description: 'Configurar pipeline de integração contínua',
      groupId: '2',
      groupName: 'Dev',
      dueDate: yesterday.add(const Duration(hours: 11)),
      priority: TaskPriority.alta,
      isCompleted: true,
    ),
    Task(
      id: '7',
      userId: '1',
      title: 'Criar paleta de cores',
      description: 'Definir a paleta de cores do novo design system',
      groupId: '1',
      groupName: 'Design',
      dueDate: yesterday.add(const Duration(hours: 9)),
      priority: TaskPriority.media,
      isCompleted: true,
    ),
    Task(
      id: '8',
      userId: '1',
      title: 'Corrigir bug no login',
      description: 'Resolver problema de autenticação no fluxo de login',
      groupId: '2',
      groupName: 'Dev',
      dueDate: yesterday.add(const Duration(hours: 14)),
      priority: TaskPriority.alta,
      isCompleted: true,
    ),
  ];
}
