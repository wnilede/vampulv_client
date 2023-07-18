import 'package:flutter/material.dart';

class CheatingIndicator extends StatelessWidget {
  const CheatingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: ((context) => Scaffold(
                  appBar: AppBar(title: const Text('Fuskinformation')),
                  body: const SingleChildScrollView(
                    padding: EdgeInsets.all(4),
                    child: Text('Vissa saker är det inte meningen att man ska göra som en vanlig spelare då det ger information om eller ändrar på saker på ett sätt som är mot reglerna. Dessa saker är indikerade med en fusksymbol. Möjligheten att utföra dessa saker finns för att det ska gå att fixa saker om det blir fel, och bygger på tillit. Alla spelare måste helt enkelt lita på varandra att inte medvetet fuska då det förstör det roliga med spelet.'),
                  ),
                )),
          ),
        );
      },
      child: Ink(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Theme.of(context).colorScheme.errorContainer,
        ),
        child: Text(
          'Fusk!',
          style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).colorScheme.onErrorContainer),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
