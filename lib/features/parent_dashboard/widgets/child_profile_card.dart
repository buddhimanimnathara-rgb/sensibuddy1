import 'package:flutter/material.dart';

class ChildProfileCard extends StatelessWidget {
  final String childName;
  final String ageRange;
  final String? diagnosis;
  final String? imageUrl;
  final VoidCallback? onTap;

  const ChildProfileCard({
    super.key,
    required this.childName,
    required this.ageRange,
    this.diagnosis,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.10),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor:
              Colors.deepPurple.withOpacity(0.12),
              backgroundImage:
              imageUrl != null &&
                  imageUrl!.isNotEmpty
                  ? NetworkImage(imageUrl!)
                  : null,
              child:
              imageUrl == null || imageUrl!.isEmpty
                  ? const Icon(
                Icons.child_care,
                size: 38,
                color: Colors.deepPurple,
              )
                  : null,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    childName,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    "Age: $ageRange Years",
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),

                  if (diagnosis != null &&
                      diagnosis!.isNotEmpty) ...[
                    const SizedBox(height: 5),

                    Text(
                      diagnosis!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}