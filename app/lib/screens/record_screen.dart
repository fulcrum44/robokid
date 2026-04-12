import 'package:flutter/material.dart';
import 'package:robokid/widgets/widgets.dart';

class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Historial',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Theme(
                      data: theme.copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: theme.iconTheme.color,
                        collapsedIconColor: theme.iconTheme.color,
                        textColor: theme.textTheme.titleMedium?.color,
                        collapsedTextColor: theme.textTheme.titleMedium?.color,
                        title: Text(
                          'Prueba 1',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text.rich(
                          TextSpan(
                            style: theme.textTheme.titleSmall,
                            children: [
                              TextSpan(
                                text: 'Creado el:',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: ' 15/04/2006 ',
                                style: theme.textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 24),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.cloud_download_outlined,
                                size: 24,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Theme(
                      data: theme.copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        iconColor: theme.iconTheme.color,
                        collapsedIconColor: theme.iconTheme.color,
                        textColor: theme.textTheme.titleMedium?.color,
                        collapsedTextColor: theme.textTheme.titleMedium?.color,
                        title: Text(
                          'Prueba 2',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text.rich(
                          TextSpan(
                            style: theme.textTheme.titleSmall,
                            children: [
                              TextSpan(
                                text: 'Creado el:',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: ' 20/04/2006 ',
                                style: theme.textTheme.titleSmall,
                              ),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 24),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.cloud_download_outlined,
                                size: 24,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
