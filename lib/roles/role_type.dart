import 'package:vampulv/roles/apprentice_seer.dart';
import 'package:vampulv/roles/card_turner.dart';
import 'package:vampulv/roles/cupid.dart';
import 'package:vampulv/roles/drunk.dart';
import 'package:vampulv/roles/gang_member.dart';
import 'package:vampulv/roles/hoodler.dart';
import 'package:vampulv/roles/hunter.dart';
import 'package:vampulv/roles/lonely_pulv.dart';
import 'package:vampulv/roles/lycan.dart';
import 'package:vampulv/roles/priest.dart';
import 'package:vampulv/roles/prince.dart';
import 'package:vampulv/roles/role.dart';
import 'package:vampulv/roles/rule.dart';
import 'package:vampulv/roles/seer.dart';
import 'package:vampulv/roles/suicide_bomber.dart';
import 'package:vampulv/roles/tanner.dart';
import 'package:vampulv/roles/vampulv.dart';
import 'package:vampulv/roles/villager.dart';
import 'package:vampulv/roles/witch.dart';

enum RoleType {
  vampulv(
    displayName: 'Vampulv',
    description: 'Döda alla som inte är vampulver',
    detailedDescription: 'Spelat avslutas och du vinner om det endast är vampulver kvar. Du vet vem de andra vampulverna är, och du vaknar under natten tillsammans med alla andra vampulver för att rösta om vem ni ska attakera. En av de spelare med flest röster väljes sedan slumpmässigt och förlorar ett liv. Du får reda på vad de andra vampulverna röstade på och resultatet av slumpningen efter att du lagt din röst. Röster kan också läggas på att inte döda någon, och det räknas som en spelare vid slumpningen.',
    imageVariations: 3,
  ),
  lonelyPulv(
    displayName: 'Självisk vampulv',
    description: 'Döda alla andra',
    detailedDescription: 'Du är en vampulv förutom att du endast vinner om du är den enda spelaren kvar i slutet.',
  ),
  villager(
    displayName: 'Bybo',
    description: 'Normal medborgare i byn',
    detailedDescription: 'Om alla dina kort är bybor så är du en borgmästare. Borgmästare har en extra röst när det röstas om avrättning.',
    imageVariations: 10,
  ),
  // pacifist(
  //   displayName: 'Pasifist',
  //   description: 'Rösta nej till avrättningar',
  //   detailedDescription: 'Vid röstning om avrättning måste du alltid rösta emot.',
  // ),
  // idiot(
  //   displayName: 'Idiot',
  //   description: 'Rösta ja till avrättningar',
  //   detailedDescription: 'Vid röstning om avrättning måste du alltid rösta för.',
  // ),
  seer(
    displayName: 'Spådam',
    description: 'Se vilka som är vampulver',
    detailedDescription: 'Varje natt väljer du en person och du får sedan reda på huruvida någon av denna persons roller är vampulv.',
  ),
  apprenticeSeer(
    displayName: 'Spådams lärling',
    description: 'Spådamssubstitut',
    detailedDescription: 'Om det inte existerar någon spådam så får du samma kraft som en spådam.',
  ),
  lycan(
    displayName: 'Lycan',
    description: 'See ut som vampulv',
    detailedDescription: 'När spådamen använder sin kraft på dig så ser du ut som om du är en vampulv.',
  ),
  priest(
    displayName: 'Präst',
    description: 'Skydda en person per natt',
    detailedDescription: 'Varje natt väljer du om du vill aktivera din kraft och i så fall väljer du en person som du inte valde förra natten. Denna person kan inte bli skadad av vampulvernas kraft under den natten.',
  ),
  prince(
    displayName: 'Prins',
    description: 'Skydd mot avrättning',
    detailedDescription: 'När du ska bli avrättad första gången visas det för alla att du är prins och du blir inte avrättad.',
  ),
  gangMember(
    displayName: 'Gängmedlem',
    description: 'Se andra gängmedlemmar',
    detailedDescription: 'Du vet vilka andra som är gängmedlemmar.',
    imageVariations: 2,
  ),
  tanner(
    displayName: 'Tanner',
    description: 'Bli avrättad',
    detailedDescription: 'När spelet är slut så vinner du om du blev avrättad och förlorar om du inte blev det.',
  ),
  hoodler(
    displayName: 'Hoodler',
    description: 'Döda två specifika personer',
    detailedDescription: 'Under andra natten väljer du två personer. När spelet är slut så vinner du om båda dessa personer är döda och förlorar om någon av dem lever.',
  ),
  cupid(
    displayName: 'Cupid',
    description: 'Samanfläta två spelares öden',
    detailedDescription: 'Välj två personer under andra natten. När en av dessa dör så förlorar den andra ett liv.',
  ),
  witch(
    displayName: 'Häxa',
    description: 'Hela och förgifta',
    detailedDescription: 'Varje natt får du välja om du vill hela någon, och i så fall vem. Om denna person inte har fullt med liv så får den ett liv till. På samma sätt får du välja huruvida du vill förgifta någon, och i så fall vem. Denna person förlorar i så fall ett liv. Du kan dock bara välja att hela en gång och förgifta en gång under hela spelet.',
  ),
  hunter(
    displayName: 'Jägare',
    description: 'Sjut när du dör',
    detailedDescription: 'Välj en annan spelare som förlorar ett liv när du dör.',
  ),
  suicideBomber(
    displayName: 'Självmordsbombare',
    description: 'Spränga dina grannar när du dör',
    detailedDescription: 'När du dör så skadas den person som sitter till höger om dig ett liv och den till vänster ett liv.',
  ),
  cardTurner(
    displayName: 'Kortvändare',
    description: 'Visa andra andras kort',
    detailedDescription: 'Varje natt där någon har dött det senaste dygnet väljer du två personer. Den ena ser sedan ett slumpmässigt av den andres roller.',
  ),
  // erasurer(
  //   displayName: '10001010',
  //   description: 'Stänga av andras krafter',
  //   detailedDescription: 'Varje natt väljer du om du vill aktivera din kraft och i så fall väljer du en person som du inte valde förra natten. Denna person kan inte aktivera några krafter under natten.',
  // ),
  drunk(
    displayName: 'Fyllo',
    description: 'Få nya roller tredje natten',
    detailedDescription: 'Tredje natten får du nya roller. Du vet inte om att du är ett fyllo fören detta händer, eftersom fyllot ser ut som en bybo.',
    imageVariations: 10, // Not really, but it uses the villagers images.
  );

  static Role hej() {
    throw UnimplementedError();
  }

  const RoleType({
    required this.displayName,
    required this.description,
    required this.detailedDescription,
    this.imageVariations = 1,
  });

  final String displayName;
  final String description;
  final String detailedDescription;

  final int imageVariations;

  Role produceRole() => switch (this) {
        RoleType.vampulv => Vampulv(),
        RoleType.lonelyPulv => LonelyPulv(),
        RoleType.villager => Villager(),
        RoleType.seer => Seer(),
        RoleType.apprenticeSeer => ApprenticeSeer(),
        RoleType.lycan => Lycan(),
        RoleType.priest => Priest(),
        RoleType.prince => Prince(),
        RoleType.gangMember => GangMember(),
        RoleType.tanner => Tanner(),
        RoleType.hoodler => Hoodler(),
        RoleType.cupid => Cupid(),
        RoleType.witch => Witch(),
        RoleType.hunter => Hunter(),
        RoleType.suicideBomber => SuicideBomber(),
        RoleType.cardTurner => CardTurner(),
        RoleType.drunk => Drunk(),
      };

  Rule? produceRule() => switch (this) {
        RoleType.vampulv => VampulvRule(),
        _ => null,
      };
}
