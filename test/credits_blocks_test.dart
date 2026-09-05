import 'package:flutter_test/flutter_test.dart';
import 'package:pyregrove/ui/credits_screen.dart';

void main() {
  test('hard-wrapped paragraph coalesces into one block', () {
    final b = parseCreditsBlocks(
        'First line of a paragraph\nsecond line continues\n\nNext para');
    expect(b.length, 2);
    expect(b[0].kind, 'para');
    expect(b[0].text, 'First line of a paragraph second line continues');
    expect(b[1].text, 'Next para');
  });

  test('bullet with indented continuation joins; next bullet splits', () {
    final b = parseCreditsBlocks(
        '- **Music** — first\n  continuation line.\n- Second bullet');
    expect(b.length, 2);
    expect(b[0].kind, 'item');
    expect(b[0].text, 'Music — first continuation line.');
    expect(b[1].text, 'Second bullet');
  });

  test('headers stand alone and strip md noise', () {
    final b = parseCreditsBlocks('## Third-party `art`\nbody');
    expect(b[0].kind, 'header');
    expect(b[0].depth, 2);
    expect(b[0].text, 'Third-party art');
    expect(b[1].kind, 'para');
  });

  test('real CREDITS.md shape: para then header then bullets', () {
    final b = parseCreditsBlocks('# Title\n\nIntro one\nintro two.\n\n'
        '## Section\n\n- a — https://x — y.\n- b\n  cont.\n');
    expect(b.map((e) => e.kind).toList(),
        ['header', 'para', 'header', 'item', 'item']);
    expect(b[1].text, 'Intro one intro two.');
    expect(b[4].text, 'b cont.');
  });
}
