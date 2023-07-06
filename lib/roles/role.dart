import 'package:vampulv/game.dart';
import 'package:vampulv/player.dart';
import 'package:vampulv/roles/event.dart';
import 'package:vampulv/roles/vampulv.dart';
import 'package:vampulv/roles/villager.dart';

abstract class Role {
  //Game changesBeforeNight(Game game) => game;
  List<RoleReaction> reactions;
  RoleType type;
  Role({required this.type, this.reactions = const []});
  factory Role.fromType(RoleType roleType) => switch (roleType) {
        RoleType.vampulv => Vampulv(),
        RoleType.villager => Villager(),
        _ => throw UnimplementedError("Have not created class for role type '$roleType' yet."),
      };
}

class RoleReaction<T extends Event> {
  int priority;

  /// Must return Game to set entire game, Player to set owner or InputHandler to add an input handler to the owner.
  dynamic Function(Game game, Player owner) applyer;

  RoleReaction({required this.priority, required this.applyer});
}

enum RoleType {
  vampulv('Vampulv', 'Döda alla som inte är vampulver', 'Spelat avslutas och du vinner om det endast är vampulver kvar. Du vet vem de andra vampulverna är, och du vaknar under natten tillsammans med alla andra vampulver för att rösta om vem ni ska attakera. En av de spelare med flest röster väljes sedan slumpmässigt och förlorar ett liv. Du får reda på vad de andra vampulverna röstade på och resultatet av slumpningen efter att du lagt din röst. Röster kan också läggas på att inte döda någon, och det räknas som en spelare vid slumpningen.'),
  villager('Bybo', 'Normal medborgare i byn', 'Om alla dina kort är bybor så är du en borgmästare. Borgmästare har en extra röst när det röstas om avrättning.'),
  idiot('Idiot', 'Rösta alltid för att avrätta dig själv', 'Vid röstning om avrättning av dig själv måste du alltid rösta för.'),
  pacifist('Pasifist', 'Rösta nej till avrättningar', 'Vid röstning om avrättning måste du alltid rösta emot.'),
  drunk('Fyllo', 'Få nya roller tredje natten', 'Tredje natten får du nya roller. Du vet inte om att du är ett fyllo fören detta händer, då fyllot ser ut som en bybo.'),
  lonelyWolf('Självisk vampyr', 'Döda alla andra', 'Du är en vampulv förutom att du endast vinner om du är den enda spelaren kvar i slutet.'),
  prince('Prins', 'Skydd mot avrättning', 'När du ska bli avrättad första gången visas det för alla att du är prins och du blir inte avrättad.'),
  priest('Präst', 'Skydda en person per natt', 'Varje natt väljer du om du vill aktivera din kraft och i så fall väljer du en person som du inte valde förra natten. Denna person kan inte bli skadad av vampulvernas kraft under den natten.'),
  suicideBomber('Självmordsbombare', 'Spränga dina grannar när du dör', 'När du dör så skadas den person som sitter till höger om dig ett liv och den till vänster ett liv.'),
  hoodler('Hoodler', 'Döda två specifika personer', 'Under andra natten väljer du två personer. När spelet är slut så vinner du om båda dessa personer är döda och förlorar om någon av dem lever.'),
  tanner('Tanner', 'Bli avrättad', 'När spelet är slut så vinner du om du blev avrättad och förlorar om du inte blev det.'),
  erasurer('10001010', 'Stänga av andras krafter', 'Varje natt väljer du om du vill aktivera din kraft och i så fall väljer du en person som du inte valde förra natten. Denna person kan inte aktivera några krafter under natten.'),
  cardTurner('Kortvändare', 'Visa andra andras kort', 'Varje natt där någon har dött det senaste dygnet väljer du två personer. Den ena ser sedan ett slumpmässigt av den andres roller.'),
  apprenticeSeer('Spådams lärling', 'Spådamssubstitut', 'Om det inte existerar någon spådam så får du samma kraft som en spådam.'),
  gangMember('Gängmedlem', 'Se andra gängmedlemmar', 'Du vet vilka andra som är gängmedlemmar.'),
  lycan('Lycan', 'See ut som vampulv', 'När spådamen använder sin kraft på dig så ser du ut som om du är en vampulv.'),
  cupid('Cupid', 'Samanfläta två spelares öden', 'Välj två personer under andra natten. När en av dessa dör så förlorar den andra ett liv.'),
  hunter('Jägare', 'Sjut när du dör', 'När du dör, välj en annan spelare som förlorar ett liv.'),
  witch('Häxa', 'Hela och förgifta', 'Varje natt får du välja om du vill hela någon, och i så fall vem. Om denna person inte har fullt med liv så får den ett liv till. På samma sätt får du välja huruvida du vill förgifta någon, och i så fall vem. Denna person förlorar i så fall ett liv. Du kan dock bara välja att hela en gång och förgifta en gång under hela spelet.'),
  seer('Spådam', 'Se vilka som är vampulver', 'Varje natt väljer du en person och du får sedan reda på huruvida någon av denna persons roller är vampulv.');

  const RoleType(this.displayName, this.description, this.detailedDescription);

  final String displayName;
  final String description;
  final String detailedDescription;
}
