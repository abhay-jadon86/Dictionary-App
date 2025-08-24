class DictionaryDart {
  Meta meta;
  int? hom;
  Hwi hwi;
  String fl;
  List<DictionaryDartIn> ins;
  String? gram;
  List<DictionaryDartDef> def;
  List<Dro>? dros;
  List<String>? dxnls;
  List<String> shortdef;
  List<Uro>? uros;

  DictionaryDart({
    required this.meta,
    this.hom,
    required this.hwi,
    required this.fl,
    required this.ins,
    this.gram,
    required this.def,
    this.dros,
    this.dxnls,
    required this.shortdef,
    this.uros,
  });

  factory DictionaryDart.fromJson(Map<String, dynamic> json) {
    return DictionaryDart(
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : throw Exception("Missing required field: meta"),
      hwi: json['hwi'] != null ? Hwi.fromJson(json['hwi']) : throw Exception("Missing required field: hwi"),
      fl: json['fl'] ?? 'unknown',
      shortdef: json['shortdef'] != null ? (json['shortdef'] as List).cast<String>() : [],
      hom: json['hom'],
      ins: (json['ins'] as List?)?.map((e) => DictionaryDartIn.fromJson(e)).toList() ?? [],
      gram: json['gram'],
      def: (json['def'] as List?)?.map((e) => DictionaryDartDef.fromJson(e)).toList() ?? [],
      dros: (json['dros'] as List?)?.map((e) => Dro.fromJson(e)).toList(),
      dxnls: (json['dxnls'] as List?)?.cast<String>(),
      uros: (json['uros'] as List?)?.map((e) => Uro.fromJson(e)).toList(),
    );
  }
}

class DictionaryDartDef {
  List<List<List<dynamic>>> sseq;

  DictionaryDartDef({
    required this.sseq,
  });

  factory DictionaryDartDef.fromJson(Map<String, dynamic> json) {
    return DictionaryDartDef(
      sseq: (json['sseq'] as List).map((e) => (e as List).map((e) => e as List).toList()).toList(),
    );
  }
}

class DictionaryDartIn {
  String? il;
  String inIf;
  String? ifc;

  DictionaryDartIn({
    this.il,
    required this.inIf,
    this.ifc,
  });

  factory DictionaryDartIn.fromJson(Map<String, dynamic> json) {
    return DictionaryDartIn(
      il: json['il'],
      inIf: json['if'],
      ifc: json['ifc'],
    );
  }
}

class Dro {
  String drp;
  List<DroDef> def;
  List<Vr>? vrs;

  Dro({
    required this.drp,
    required this.def,
    this.vrs,
  });

  factory Dro.fromJson(Map<String, dynamic> json) {
    return Dro(
      drp: json['drp'],
      def: (json['def'] as List).map((e) => DroDef.fromJson(e)).toList(),
      vrs: (json['vrs'] as List?)?.map((e) => Vr.fromJson(e)).toList(),
    );
  }
}

class DroDef {
  List<List<List<dynamic>>> sseq;

  DroDef({
    required this.sseq,
  });

  factory DroDef.fromJson(Map<String, dynamic> json) {
    return DroDef(
      sseq: (json['sseq'] as List).map((e) => (e as List).map((e) => e as List).toList()).toList(),
    );
  }
}

class Vr {
  String vl;
  String va;

  Vr({
    required this.vl,
    required this.va,
  });

  factory Vr.fromJson(Map<String, dynamic> json) {
    return Vr(
      vl: json['vl'],
      va: json['va'],
    );
  }
}

class Hwi {
  String hw;
  List<Pr>? prs;
  List<Altpr>? altprs;

  Hwi({
    required this.hw,
    this.prs,
    this.altprs,
  });

  factory Hwi.fromJson(Map<String, dynamic> json) {
    return Hwi(
      hw: json['hw'],
      prs: (json['prs'] as List?)?.map((e) => Pr.fromJson(e)).toList(),
      altprs: (json['altprs'] as List?)?.map((e) => Altpr.fromJson(e)).toList(),
    );
  }
}

class Pr {
  String ipa;
  Sound sound;

  Pr({
    required this.ipa,
    required this.sound,
  });

  factory Pr.fromJson(Map<String, dynamic> json) {
    return Pr(
      ipa: json['ipa'],
      sound: Sound.fromJson(json['sound']),
    );
  }
}

class Sound {
  String audio;

  Sound({
    required this.audio,
  });

  factory Sound.fromJson(Map<String, dynamic> json) {
    return Sound(
      audio: json['audio'],
    );
  }
}

class Altpr {
  String ipa;

  Altpr({
    required this.ipa,
  });

  factory Altpr.fromJson(Map<String, dynamic> json) {
    return Altpr(
      ipa: json['ipa'],
    );
  }
}

class Meta {
  String id;
  String uuid;
  Src src;
  Section section;
  String? highlight;
  List<String> stems;
  AppShortdef appShortdef;
  bool offensive;
  Target? target;

  Meta({
    required this.id,
    required this.uuid,
    required this.src,
    required this.section,
    this.highlight,
    required this.stems,
    required this.appShortdef,
    required this.offensive,
    this.target,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      id: json['id'],
      uuid: json['uuid'],
      src: Src.values.firstWhere((e) => e.toString().split('.').last == json['src']),
      section: Section.values.firstWhere((e) => e.toString().split('.').last == json['section']),
      highlight: json['highlight'],
      stems: (json['stems'] as List).cast<String>(),
      appShortdef: AppShortdef.fromJson(json['appshortdef']),
      offensive: json['offensive'],
      target: json['target'] != null ? Target.fromJson(json['target']) : null,
    );
  }
}

class AppShortdef {
  String hw;
  Fl fl;
  List<String> def;

  AppShortdef({
    required this.hw,
    required this.fl,
    required this.def,
  });

  factory AppShortdef.fromJson(Map<String, dynamic> json) {
    return AppShortdef(
      hw: json['hw'],
      fl: Fl.values.firstWhere((e) => e.toString().split('.').last == json['fl']),
      def: (json['def'] as List).cast<String>(),
    );
  }
}

class Target {
  String tuuid;
  String tsrc;

  Target({
    required this.tuuid,
    required this.tsrc,
  });

  factory Target.fromJson(Map<String, dynamic> json) {
    return Target(
      tuuid: json['tuuid'],
      tsrc: json['tsrc'],
    );
  }
}

class Uro {
  String ure;
  List<Pr>? prs;
  String fl;
  List<List<dynamic>> utxt;
  List<UroIn>? ins;
  String? gram;

  Uro({
    required this.ure,
    this.prs,
    required this.fl,
    required this.utxt,
    this.ins,
    this.gram,
  });

  factory Uro.fromJson(Map<String, dynamic> json) {
    return Uro(
      ure: json['ure'],
      prs: (json['prs'] as List?)?.map((e) => Pr.fromJson(e)).toList(),
      fl: json['fl'],
      utxt: (json['utxt'] as List).map((e) => e as List).toList(),
      ins: (json['ins'] as List?)?.map((e) => UroIn.fromJson(e)).toList(),
      gram: json['gram'],
    );
  }
}

class UroIn {
  String ifc;
  String inIf;

  UroIn({
    required this.ifc,
    required this.inIf,
  });

  factory UroIn.fromJson(Map<String, dynamic> json) {
    return UroIn(
      ifc: json['ifc'],
      inIf: json['if'],
    );
  }
}

enum Fl {
  noun('noun'),
  verb('verb');

  final String value;
  const Fl(this.value);

  @override
  String toString() => value;
}

enum Src {
  learners('learners');

  final String value;
  const Src(this.value);

  @override
  String toString() => value;
}

enum Section {
  alpha('alpha');

  final String value;
  const Section(this.value);

  @override
  String toString() => value;
}