import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const groveLocales = [
  Locale('en'),
  Locale('fr'),
  Locale('es'),
  Locale('pt', 'BR'),
];
const groveLanguages = {
  'system': 'System',
  'en': 'English',
  'fr': 'Français',
  'es': 'Español',
  'pt': 'Português (Brasil)',
};

class GroveLanguage {
  static final choice = ValueNotifier<String>('system');
  static String valid(Object? v) =>
      v is String && groveLanguages.containsKey(v) ? v : 'system';
  static Locale? locale(String v) => switch (v) {
    'fr' => const Locale('fr'),
    'es' => const Locale('es'),
    'pt' => const Locale('pt', 'BR'),
    'en' => const Locale('en'),
    _ => null,
  };
  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    choice.value = valid(p.get('interfaceLanguage'));
  }

  static Future<bool> save(String v) async {
    choice.value = valid(v);
    return (await SharedPreferences.getInstance()).setString(
      'interfaceLanguage',
      choice.value,
    );
  }
}

/// English source keys are not translated inside saves, levels or telemetry.
/// Order: French / Spanish / Brazilian Portuguese; unknown text stays literal.
const groveCatalog = <String, List<String>>{
  'PLAY': ['JOUER', 'JUGAR', 'JOGAR'],
  'SHOP': ['BOUTIQUE', 'TIENDA', 'LOJA'],
  'SETTINGS': ['PARAMÈTRES', 'AJUSTES', 'CONFIGURAÇÕES'],
  'CREDITS': ['CRÉDITS', 'CRÉDITOS', 'CRÉDITOS'],
  'DAILY DELVE': [
    'EXPÉDITION DU JOUR',
    'EXPEDICIÓN DIARIA',
    'EXPEDIÇÃO DIÁRIA',
  ],
  'Delve the burning grove': [
    'Explorez le bosquet en flammes',
    'Explora la arboleda en llamas',
    'Explore o bosque em chamas',
  ],
  'Language': ['Langue', 'Idioma', 'Idioma'],
  'System': ['Système', 'Sistema', 'Sistema'],
  'Close': ['Fermer', 'Cerrar', 'Fechar'],
  'Menus, main controls and Forest Edge lessons are translated. Item descriptions, later stories, legal notices and some summaries remain in English.': [
    'Les menus, les commandes principales et les leçons de la Lisière sont traduits. Les objets, les histoires suivantes, les mentions légales et certains résumés restent en anglais.',
    'Los menús, los controles principales y las lecciones de Linde del Bosque están traducidos. Los objetos, las historias posteriores, los avisos legales y algunos resúmenes siguen en inglés.',
    'Os menus, os controles principais e as lições da Orla da Floresta estão traduzidos. Os itens, as histórias seguintes, os avisos legais e alguns resumos continuam em inglês.',
  ],
  'Could not save language on this device.': [
    'Impossible d’enregistrer la langue sur cet appareil.',
    'No se pudo guardar el idioma en este dispositivo.',
    'Não foi possível salvar o idioma neste dispositivo.',
  ],
  'DIFFICULTY': ['DIFFICULTÉ', 'DIFICULTAD', 'DIFICULDADE'],
  'Easy': ['Facile', 'Fácil', 'Fácil'],
  'Medium': ['Moyen', 'Medio', 'Médio'],
  'Hard': ['Difficile', 'Difícil', 'Difícil'],
  'Enemies think faster and reach farther on Hard. Easy adds a heart of slack.': [
    'En Difficile, les ennemis réagissent plus vite et portent plus loin. Facile ajoute un cœur.',
    'En Difícil, los enemigos reaccionan más rápido y alcanzan más lejos. Fácil añade un corazón.',
    'No Difícil, os inimigos reagem mais rápido e alcançam mais longe. Fácil adiciona um coração.',
  ],
  'Forgiving jumps': [
    'Sauts assistés',
    'Saltos asistidos',
    'Saltos assistidos',
  ],
  'Full-height taps, easier double jumps and a gentler fall. Turn off for classic hold-to-jump controls. Applies at the next level.': [
    'Un toucher donne un saut complet, le double saut est plus simple et la chute plus douce. Désactivez pour les commandes classiques à maintenir. Au prochain niveau.',
    'Un toque da un salto completo, el doble salto es más fácil y la caída más suave. Desactiva para los controles clásicos de mantener pulsado. En el próximo nivel.',
    'Um toque dá um salto completo, o salto duplo fica mais fácil e a queda mais suave. Desative para os controles clássicos de segurar. No próximo nível.',
  ],
  'Music': ['Musique', 'Música', 'Música'],
  'Sound effects': ['Effets sonores', 'Efectos de sonido', 'Efeitos sonoros'],
  'Haptics': ['Vibrations', 'Vibración', 'Vibração'],
  'Vibrate on hits and boss beats': [
    'Vibrer lors des coups et des attaques de boss',
    'Vibrar con golpes y ataques de jefes',
    'Vibrar nos golpes e ataques dos chefes',
  ],
  'Screen shake': [
    'Secousses de caméra',
    'Sacudidas de cámara',
    'Tremor da câmera',
  ],
  'Camera kick on hits and boss beats': [
    'Secousses lors des coups et des attaques de boss',
    'Sacudidas con golpes y ataques de jefes',
    'Tremor nos golpes e ataques dos chefes',
  ],
  'Fill screen': ['Plein écran', 'Pantalla completa', 'Tela cheia'],
  'Use the whole width of wide phones': [
    "Utiliser toute la largeur des téléphones larges",
    'Usar todo el ancho de los teléfonos anchos',
    'Usar toda a largura dos celulares largos',
  ],
  'Control size': [
    'Taille des commandes',
    'Tamaño de controles',
    'Tamanho dos controles',
  ],
  'Touch buttons; applies at the next level': [
    'Boutons tactiles ; au prochain niveau',
    'Botones táctiles; en el próximo nivel',
    'Botões de toque; no próximo nível',
  ],
  'Small': ['Petit', 'Pequeño', 'Pequeno'],
  'Normal': ['Normal', 'Normal', 'Normal'],
  'Large': ['Grand', 'Grande', 'Grande'],
  'Swap control sides': [
    'Inverser les commandes',
    'Intercambiar controles',
    'Trocar lados dos controles',
  ],
  'Move-pad on the right, action buttons on the left; applies at the next level':
      [
        'Déplacement à droite, actions à gauche ; au prochain niveau',
        'Movimiento a la derecha, acciones a la izquierda; en el próximo nivel',
        'Movimento à direita, ações à esquerda; no próximo nível',
      ],
  'Control height': [
    'Hauteur des commandes',
    'Altura de controles',
    'Altura dos controles',
  ],
  'Lift the buttons off the bottom edge; applies at the next level': [
    'Éloigner les boutons du bord inférieur ; au prochain niveau',
    'Alejar los botones del borde inferior; en el próximo nivel',
    'Afastar os botões da borda inferior; no próximo nível',
  ],
  'Flush': ['Bas', 'Abajo', 'Baixo'],
  'Raised': ['Relevé', 'Elevado', 'Elevado'],
  'High': ['Haut', 'Alto', 'Alto'],
  'Audio unavailable': [
    'Audio indisponible',
    'Audio no disponible',
    'Áudio indisponível',
  ],
  'Credits & Licenses': [
    'Crédits et licences',
    'Créditos y licencias',
    'Créditos e licenças',
  ],
  'PAUSED': ['PAUSE', 'PAUSA', 'PAUSADO'],
  'Resume': ['Reprendre', 'Continuar', 'Continuar'],
  'Restart level': [
    'Recommencer le niveau',
    'Reiniciar nivel',
    'Reiniciar nível',
  ],
  'Leave level': ['Quitter le niveau', 'Salir del nivel', 'Sair do nível'],
  'FALLEN...': ['TOMBÉ...', 'HAS CAÍDO...', 'VOCÊ CAIU...'],
  'Try again': ['Réessayer', 'Reintentar', 'Tentar de novo'],
  'Leave': ['Quitter', 'Salir', 'Sair'],
  'LEVEL CLEAR!': ['NIVEAU TERMINÉ !', '¡NIVEL SUPERADO!', 'NÍVEL CONCLUÍDO!'],
  'Finished': ['Terminé', 'Terminado', 'Concluído'],
  'All chests': ['Tous les coffres', 'Todos los cofres', 'Todos os baús'],
  'Low damage': ['Peu de dégâts', 'Poco daño', 'Pouco dano'],
  'Replay': ['Rejouer', 'Repetir', 'Rejogar'],
  'Levels': ['Niveaux', 'Niveles', 'Níveis'],
  'Next level': ['Niveau suivant', 'Siguiente nivel', 'Próximo nível'],
  'Continue': ['Continuer', 'Continuar', 'Continuar'],
  'Forest Edge': ['Lisière', 'Linde del Bosque', 'Orla da Floresta'],
  'Hold LEFT/RIGHT to run. Tap JUMP - tap again in the air to double-jump!': [
    'Maintenez GAUCHE/DROITE pour courir. Touchez SAUT, puis encore en l’air pour le double saut !',
    'Mantén IZQUIERDA/DERECHA para correr. Toca SALTAR y otra vez en el aire para el salto doble.',
    'Segure ESQUERDA/DIREITA para correr. Toque em PULAR e de novo no ar para o salto duplo!',
  ],
  'Light a campfire to save your progress. Fall here and you come back to it.': [
    'Allumez un feu pour sauvegarder. Si vous tombez, vous y revenez.',
    'Enciende una fogata para guardar el progreso. Si caes, volverás a ella.',
    'Acenda uma fogueira para salvar o progresso. Se cair, você volta a ela.',
  ],
  'Tap SWORD to swing - three quick taps chain a combo.': [
    'Touchez ÉPÉE pour frapper. Trois touchers rapides forment un combo.',
    'Toca ESPADA para golpear. Tres toques rápidos encadenan un combo.',
    'Toque em ESPADA para atacar. Três toques rápidos formam um combo.',
  ],
  'Tap DASH to roll through danger. Hold DOWN to drop through thin platforms.': [
    'Touchez ESQUIVE pour rouler. Maintenez BAS pour traverser les plateformes fines.',
    'Toca ESQUIVAR para rodar. Mantén ABAJO para bajar de plataformas finas.',
    'Toque em ESQUIVAR para rolar. Segure BAIXO para descer de plataformas finas.',
  ],
};

String groveText(String source, String languageCode) {
  final i = const {'fr': 0, 'es': 1, 'pt': 2}[languageCode];
  return i == null ? source : (groveCatalog[source]?[i] ?? source);
}

String gt(BuildContext context, String source) => groveText(
  source,
  Localizations.maybeLocaleOf(context)?.languageCode ?? 'en',
);

/// Const-friendly translated text; preserves every caller's typography.
class GroveText extends StatelessWidget {
  const GroveText(this.source, {super.key, this.style, this.textAlign});
  final String source;
  final TextStyle? style;
  final TextAlign? textAlign;
  @override
  Widget build(BuildContext context) =>
      Text(gt(context, source), style: style, textAlign: textAlign);
}

Future<void> showGroveLanguage(
  BuildContext context,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: const Color(0xFF141420),
  builder: (_) => ValueListenableBuilder<String>(
    valueListenable: GroveLanguage.choice,
    builder: (context, code, _) => Localizations.override(
      context: context,
      locale: GroveLanguage.locale(code),
      child: Builder(
        builder: (context) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gt(context, 'Language'),
                  style: const TextStyle(
                    fontSize: 22,
                    color: Color(0xFFE8A33D),
                  ),
                ),
                DropdownButton<String>(
                  key: const Key('interface-language'),
                  isExpanded: true,
                  value: code,
                  items: [
                    for (final entry in groveLanguages.entries)
                      DropdownMenuItem(
                        value: entry.key,
                        child: Text(
                          entry.key == 'system'
                              ? gt(context, entry.value)
                              : entry.value,
                        ),
                      ),
                  ],
                  onChanged: (value) async {
                    if (value == null) return;
                    final saved = await GroveLanguage.save(value);
                    if (!saved && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            gt(
                              context,
                              'Could not save language on this device.',
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
                const GroveText(
                  'Menus, main controls and Forest Edge lessons are translated. Item descriptions, later stories, legal notices and some summaries remain in English.',
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(gt(context, 'Close')),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
