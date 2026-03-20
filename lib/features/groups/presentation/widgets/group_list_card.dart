import 'package:flutter/material.dart';
import '../../data/group.entity.dart';

class GroupListCard extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;

  const GroupListCard({
    super.key,
    required this.group,
    required this.onTap,
  });

  String getInitials(String name) {
    final parts = name.trim().split(" ");

    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }

    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final membersCount = group.memberIds?.length ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),

      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),

        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),

          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F1733), Color(0xFF1B2550)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),

              border: Border.all(
                color: Colors.white.withOpacity(0.05),
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Row(
                children: [

                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF8F7BFF),
                    child: Text(
                      getInitials(group.name ?? "G"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          group.name ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          group.description ?? "",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [

                            const Icon(
                              Icons.people,
                              size: 16,
                              color: Color(0xFF8F7BFF),
                            ),

                            const SizedBox(width: 6),

                            Text(
                              "$membersCount membros",
                              style: const TextStyle(
                                color: Color(0xFF8F7BFF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.white38,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}