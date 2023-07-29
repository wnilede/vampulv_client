import '../roles/apprentice_seer.dart';
import '../roles/card_turner.dart';
import '../roles/cupid.dart';
import '../roles/drunk.dart';
import '../roles/gang_member.dart';
import '../roles/hoodler.dart';
import '../roles/hunter.dart';
import '../roles/lonely_pulv.dart';
import '../roles/lycan.dart';
import '../roles/priest.dart';
import '../roles/prince.dart';
import '../roles/seer.dart';
import '../roles/suicide_bomber.dart';
import '../roles/tanner.dart';
import '../roles/vampulv.dart';
import '../roles/villager.dart';
import '../roles/witch.dart';
import 'role.dart';
import 'rule.dart';

enum RoleType {
  vampulv(
    displayName: 'Vampulv',
    summary: 'Döda alla som inte är vampulver',
    description:
        'Spelat avslutas antingen om det endast är vampulver kvar eller om det inte är några vampulver kvar alls. I det första fallet vinner du och i det andra förlorar du[, såvida du inte också är &hoodler OR &tanner OR &lonelyPulv]. Du vet vem de andra vampulverna är[ men du vet inte om de är själviska&lonelyPulv], och du vaknar under natten tillsammans med dem för att rösta om vem ni ska attackera. En av de spelare med flest röster väljes sedan slumpmässigt och förlorar ett liv. Du får reda på vad de andra vampulverna röstade på och resultatet av slumpningen efter att du lagt din röst. Röster kan också läggas på att inte döda någon, och det räknas som en spelare vid slumpningen.',
    imageVariations: 3,
  ),
  lonelyPulv(
    displayName: 'Självisk vampulv',
    summary: 'Döda alla andra',
    description:
        'Du vinner bara om du är den enda spelaren kvar i slutet[, såvida du inte också är &hoodler OR &tanner]. Annars fungerar du som en &vampulv.',
  ),
  villager(
    displayName: 'Bybo',
    summary: 'Normal medborgare i byn',
    description:
        'Om alla dina roller är bybor[ eller &drunk] så är du en borgmästare. Borgmästare har en extra röst när det röstas om avrättning.',
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
    summary: 'Se vilka som är vampulver',
    description:
        'Varje natt väljer du en spelare och du får sedan reda på huruvida någon av denna spelares roller är [&vampulv OR &lonelyPulv OR &lycan].',
  ),
  apprenticeSeer(
    displayName: 'Spådams lärling',
    summary: 'Spådamssubstitut',
    description: 'Om det inte finns någon levande &seer så fungerar du som en sådan.',
  ),
  lycan(
    displayName: 'Lycan',
    summary: 'Se ut som vampulv',
    description: 'När en &seer använder sin kraft på dig så ser du ut som en &vampulv.',
  ),
  priest(
    displayName: 'Präst',
    summary: 'Skydda en spelare per natt',
    description:
        'Varje natt väljer du om du vill aktivera din kraft och i så fall väljer du en spelare som du inte valde förra natten. Denna spelare kan inte bli skadad av vampulvernas&vampulv kraft under den natten.',
  ),
  prince(
    displayName: 'Prins',
    summary: 'Skydd mot avrättning',
    description: 'När du ska bli lynchad första gången visas det för alla att du är prins och du blir inte lynchad.',
  ),
  gangMember(
    displayName: 'Gängmedlem',
    summary: 'Se andra gängmedlemmar',
    description: 'Du vet vilka andra som är gängmedlemmar.',
    imageVariations: 2,
  ),
  tanner(
    displayName: 'Tanner',
    summary: 'Bli avrättad',
    description:
        'När spelet är slut så vinner du om du blev lynchad och förlorar om du inte blev det.[ Om du också är &hoodler så måste du förutom att bli lynchad också uppfylla dennas vinstvillkor för att vinna.]',
  ),
  hoodler(
    displayName: 'Hoodler',
    summary: 'Döda två specifika spelare',
    description:
        'Under andra natten väljer du två spelare. När spelet är slut så vinner du om båda dessa spelare är döda och förlorar om någon av dem lever.[ Om du också är &tanner så måste du dessutom uppfylla dennas vinstvillkor för att vinna.]',
  ),
  cupid(
    displayName: 'Cupid',
    summary: 'Samanfläta två spelares öden',
    description: 'Välj två spelare under andra natten. När en av dessa dör så förlorar den andra ett liv.',
  ),
  witch(
    displayName: 'Häxa',
    summary: 'Hela och förgifta',
    description:
        'Varje natt får du välja om du vill hela någon, och i så fall vem. Om denna spelare inte har fullt med liv så får den ett liv till. På samma sätt får du välja huruvida du vill förgifta någon, och i så fall vem. Denna spelare förlorar i så fall ett liv. Du kan dock bara välja att hela en gång och förgifta en gång under hela spelet.',
  ),
  hunter(
    displayName: 'Jägare',
    summary: 'Skjut när du dör',
    description: 'När du dör väljer du en annan spelare som förlorar ett liv.',
  ),
  suicideBomber(
    displayName: 'Självmordsbombare',
    summary: 'Spränga dina grannar när du dör',
    description:
        'Om det finns någon annan levande spelare när du dör så skadas de två levande spelare som är närmast till höger och vänster om dig varsitt liv. Om detta är samma spelare så förlorar denna istället två liv.',
  ),
  cardTurner(
    displayName: 'Kortvändare',
    summary: 'Visa andra andras kort',
    description:
        'Varje natt där någon har dött det senaste dygnet väljer du två spelare. Den ena ser sedan en slumpmässig av den andres roller.',
  ),
  // erasurer(
  //   displayName: '10001010',
  //   description: 'Stänga av andras krafter',
  //   detailedDescription: 'Varje natt väljer du om du vill aktivera din kraft och i så fall väljer du en spelare som du inte valde förra natten. Denna spelare kan inte aktivera några krafter under natten.',
  // ),
  drunk(
    displayName: 'Fyllo',
    summary: 'Få nya roller tredje natten',
    description:
        'Tredje natten får du nya roller. Du vet normalt sett inte om att du är ett fyllo fören detta händer, eftersom fyllot ser ut som en &villager.[ En &cardTurner som ser den här rollen ser dock att det är ett fyllo.]',
    imageVariations: 10, // Not really, but it uses the villagers images.
  );

  static Role hej() {
    throw UnimplementedError();
  }

  const RoleType({
    required this.displayName,
    required this.summary,
    required this.description,
    this.imageVariations = 1,
  });

  final String displayName;
  final String summary;
  final String description;

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
