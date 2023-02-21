import 'dart:io';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/particles.dart';
import 'package:flame/sprite.dart';
import 'package:flame/widgets.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:restart_app/restart_app.dart';

enum CharState {
  idle,
  walk,
  dash,
  removed,
  add,
  empty
}

final chmSize = Vector2(120, 80);
final charSize = Vector2(55, 80);
late final gameSize;

void main() {

  runApp(GameWidget(game: MyGame()));
}

class MyGame extends FlameGame with HasDraggables, HasTappableComponents, HasCollisionDetection, KeyboardEvents {
  late BackgroundComponent bg;

  //input
  late final JoystickComponent joystick;
  DashSkillButton dashSkillButton = DashSkillButton();
  GameStartButton gameStartButton = GameStartButton();
  GameStartButton nextButton = GameStartButton();
  final Vector2 dialogButtonSize = Vector2.all(80);
  final Vector2 gameStartButtonSize = Vector2(256, 104);
  final Vector2 nextButtonSize = Vector2(80, 80);

  //char
  final double speed = 200;

  //Player
  late Player chm;
  bool chmFlipped = false;

  //NPC
  late NPC ko;

  //hong
  late List hong = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40];
  late final List hongName = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40];
  late List hongHP = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40];

  //gay
  late final List gay = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  late final List gayArm = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  late final List gayName = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  late List gayHP = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  //hoon
  late final List hoon = [1, 2];
  late final List hoonName = [1, 2];
  late List hoonHP = [1, 2];

  //text
  final namePaint = TextPaint(style: TextStyle(color: BasicPalette.black.color, fontSize: 17, fontFamily: "Bahnschrift"));
  final hpPaint = TextPaint(style: TextStyle(color: BasicPalette.darkRed.color, fontSize: 17, fontFamily: "Bahnschrift"));
  final titlePaint = TextPaint(style: TextStyle(color: BasicPalette.teal.color, fontSize: 83, fontFamily: "Bahnschrift", fontWeight: FontWeight.w900));
  final levelPaint = TextPaint(style: TextStyle(color: BasicPalette.black.color, fontSize: 60, fontFamily: "Bahnschrift", fontWeight: FontWeight.w700));
  final interplayTextPaint = TextPaint(style: TextStyle(color: BasicPalette.white.color, fontSize: 25));
  TextComponent level = TextComponent();
  final TextComponent chmName = TextComponent();
  final TextComponent koName = TextComponent();
  TextComponent chmHP = TextComponent();
  final TextComponent title = TextComponent();
  final TextComponent interplayText = TextComponent();
  final TextComponent endingText = TextComponent();
  double nextNum = 0;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    gameSize = size;

    //add background
    bg = BackgroundComponent(Color(0xFF104444))..size = size;
    add(bg);

    //add game start button
    gameStartButton
    ..sprite = await loadSprite("buttons/game_start_button.png")
    ..size = gameStartButtonSize
    ..position = (size - gameStartButtonSize)/2 + Vector2(0, 100);
    add(gameStartButton);

    //add title
    title
    ..text = "ChoHyunMin\n      GAME"
    ..anchor = Anchor.center
    ..textRenderer = titlePaint
    ..position = Vector2(size[0]/2, gameStartButton.y - 200);
    add(title);

    //add interplayText
    interplayText
    ..text = ""
    ..position = Vector2(40, size[1]/2 + 170)
    ..textRenderer = interplayTextPaint;
    add(interplayText);

    //add endingText
    endingText
    ..text = ""
    ..position = Vector2(40, size[1]/2 + 170)
    ..textRenderer = interplayTextPaint;
    add(endingText);

    //load next button
    nextButton
    ..sprite = await loadSprite("buttons/nextButton.png")
    ..size = dialogButtonSize
    ..paint = (Paint()..color = const Color.fromARGB(0, 255, 255, 255));

    //load dash skill button
    dashSkillButton
    ..sprite = await loadSprite("buttons/dashButton.png")
    ..size = dialogButtonSize;

    //load player chm
    List<Sprite> chmWalkImages = [
      Sprite(await images.load("chm/walk/chm_walk (1).png")),
      Sprite(await images.load("chm/walk/chm_walk (2).png"))
    ];
    List<Sprite> chmIdleImages = [
      Sprite(await images.load("chm/chm_idle.png"))
    ];
    List<Sprite> chmDashImages = [
      Sprite(await images.load("chm/chm_dash.png"))
    ];
    chm = Player(
        playerWalkAnimation: SpriteAnimation.spriteList(chmWalkImages, stepTime: 0.2),
        playerIdleAnimation: SpriteAnimation.spriteList(chmIdleImages, stepTime: 0.2),
        playerDashAnimation: SpriteAnimation.spriteList(chmDashImages, stepTime: 0.2),
    );

    chmName
    ..text = "ChoHyunMin"
    ..anchor = Anchor.center
    ..textRenderer = namePaint
    ..priority = 10;

    chmHP
    ..text = "0"
    ..anchor = Anchor.center
    ..textRenderer = hpPaint
    ..priority = 10;

    //load hong
    List<Sprite> hongWalkImages = [
      Sprite(await images.load("hong/walk/hongWalk (1).png")),
      Sprite(await images.load("hong/walk/hongWalk (2).png"))
    ];
    List<Sprite> hongIdleImages = [
      Sprite(await images.load("hong/hongIdle.png"))
    ];

    for (var i = 0; i < 40; i++) {
      hong[i] = Enemy(
          enemyWalkAnimation: SpriteAnimation.spriteList(hongWalkImages, stepTime: 0.2),
          enemyIdleAnimation: SpriteAnimation.spriteList(hongIdleImages, stepTime: 0.2),
          hp: 1,
          enemySize: charSize
      );

      hongHP[i] = TextComponent()
        ..text = "0"
        ..anchor = Anchor.center
        ..textRenderer = hpPaint;

      hongName[i] = TextComponent()
        ..text = "HongJungBin"
        ..anchor = Anchor.center
        ..textRenderer = namePaint;
    }

    //load gay
    List<Sprite> gayWalkImages = [
      Sprite(await images.load("gay/walk/gayWalk (1).png")),
      Sprite(await images.load("gay/walk/gayWalk (2).png"))
    ];
    List<Sprite> gayIdleImages = [
      Sprite(await images.load("gay/gayIdle.png"))
    ];

    for (var i = 0; i < 10; i++) {
      gay[i] = Enemy(
          enemyWalkAnimation: SpriteAnimation.spriteList(gayWalkImages, stepTime: 0.2),
          enemyIdleAnimation: SpriteAnimation.spriteList(gayIdleImages, stepTime: 0.2),
          hp: 100,
          enemySize: charSize*1.5
      );

      gayArm[i] = EnemyWeapon(weapon: await images.load("gay/walk/gayArm.png"), weaponSize: Vector2(60, 35)*1.8, anchor: Anchor.centerLeft);

      gayHP[i] = TextComponent()
        ..text = "0"
        ..anchor = Anchor.center
        ..textRenderer = hpPaint;

      gayName[i] = TextComponent()
        ..text = "KimKyungMin(Gay)"
        ..anchor = Anchor.center
        ..textRenderer = namePaint;
    }

    //load hoon
    List<Sprite> hoonWalkImages = [
      Sprite(await images.load("hoon/walk/hoonWalk (1).png")),
      Sprite(await images.load("hoon/walk/hoonWalk (2).png"))
    ];
    List<Sprite> hoonIdleImages = [
      Sprite(await images.load("hoon/hoonIdle.png"))
    ];
    List<Sprite> hoonSkillImages = [
      Sprite(await images.load("hoon/hoonSkill.png"))
    ];

    for (var i = 0; i < 2; i++) {
      hoon[i] = Enemy(
          enemyWalkAnimation: SpriteAnimation.spriteList(hoonWalkImages, stepTime: 0.2),
          enemyIdleAnimation: SpriteAnimation.spriteList(hoonSkillImages, stepTime: 0.4),
          hp: 2200,
          enemySize: Vector2(250, 320)
      );

      hoonHP[i] = TextComponent()
        ..text = "0"
        ..anchor = Anchor.center
        ..textRenderer = hpPaint;

      hoonName[i] = TextComponent()
        ..text = "KimKyungHoon"
        ..anchor = Anchor.center
        ..textRenderer = namePaint;
    }

    //load ko
    ko = NPC(image: await images.load("ko/koIdle.png"))
    ..position = Vector2(100, 100);

    //load level text
    level
    ..text = "LEVEL 1"
    ..anchor = Anchor.center
    ..textRenderer = levelPaint
    ..position = Vector2((size[0]-level.size[0])/2, 40);

    //load NPC name
    koName
    ..text = "KoJooWon"
    ..anchor = Anchor.center
    ..textRenderer = namePaint;

    //load joystick
    final knobPaint = BasicPalette.black.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.blue.withAlpha(100).paint();
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: knobPaint),
      background: CircleComponent(radius: 55, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 35, bottom: 35),
    );
  }


  int random(int min, int max) {
    return min + Random().nextInt(max - min);
  }

  var talkList = [
    'Touch the "next button" to talk',
    "KoJooWon: Jungbin is strange!!\nHyunmin run away!!",
    "ChoHyunMin: Why is HongJungbin\nin this state?",
    "KoJooWon: I don't know",
    "KoJooWon: Over there, Kyungmin is coming!\ni'll be looking for a solution\nyou fight them",
    "ChoHyunMin: Did you find the solution?",
    "KoJooWon: no i didn't find it",
    "KoJooWon: omg! Kyunghoon and\nour friends are coming again!!"
  ];

  var endLevel = 0;

  void addHong(int i) {
    hong[i].position = Vector2(random(0, size[0].toInt()).toDouble(), random(0, size[1].toInt()).toDouble());
    hong[i].current = CharState.add;
    add(hong[i]);
    add(hongName[i]);
    add(hongHP[i]);
  }

  void addGay(int i) {
    gay[i].position = size / 2;
    gay[i].current = CharState.add;
    add(gay[i]);
    add(gayArm[i]);
    add(gayName[i]);
    add(gayHP[i]);
  }

  void addHoon(int i) {
    hoon[i].position = size / 2;
    hoon[i].current = CharState.add;
    add(hoon[i]);
    add(hoonName[i]);
    add(hoonHP[i]);
  }

  var sec = 60.0;
  var timer = 0;
  var hoonAttack = false;

  @override
  void update(double dt) {
    super.update(dt);

    sec -= 1*dt;

    if (sec <= 0) {
      timer += 1;
    }

    if (chm.isInterplay) {
      nextButton.paint = (Paint()..color = const Color.fromARGB(255, 255, 255, 255));
      interplayText.text = talkList[nextNum.floor()];

      if (nextButton.isPressed){
        nextNum = 1;
      }
    } else if (!chm.isInterplay) {
      interplayText.text = "";
      nextButton.paint = (Paint()..color = const Color.fromARGB(0, 255, 255, 255));
    }

    if (nextNum >= 1 && endLevel == 0) {
      nextButton.paint = (Paint()..color = const Color.fromARGB(0, 255, 255, 255));
      Future.delayed(const Duration(milliseconds: 5000), () {
        ko.position = Vector2(-999, -999);

        add(level);
        Future.delayed(const Duration(milliseconds: 1), () {
          addHong(0);
          Future.delayed(const Duration(milliseconds: 5000), () {
            addHong(1);
            Future.delayed(const Duration(milliseconds: 5000), () {
              addHong(2);
              Future.delayed(const Duration(milliseconds: 5000), () {
                addHong(3);
                Future.delayed(const Duration(milliseconds: 5000), () {
                  addHong(4);
                  Future.delayed(const Duration(milliseconds: 5000), () {
                    addHong(5);
                    endLevel = 1;
                  });
                });
              });
            });
          });
        });
      });
    }
    else if (hong[0].current == CharState.removed && hong[1].current == CharState.removed && hong[2].current == CharState.removed
        && hong[3].current == CharState.removed && hong[4].current == CharState.removed && hong[5].current == CharState.removed && endLevel == 1) {
      hong[0].current = CharState.empty;
      Future.delayed(const Duration(milliseconds: 100), () {
        ko.position = Vector2(100, 100);
        chm.power = 3;
        remove(nextButton);

        Future.delayed(const Duration(milliseconds: 300), () {
          chm.position = Vector2(ko.x + 70, ko.y);
          nextNum = 2;
          Future.delayed(const Duration(milliseconds: 5000), () {
            nextNum = 3;
            Future.delayed(const Duration(milliseconds: 4000), () {
              nextNum = 4;
              Future.delayed(const Duration(milliseconds: 10000), () {
                level.text = "LEVEL 2";
                chm.hp = 10;
                ko.position = Vector2(-999, -999);

                Future.delayed(const Duration(milliseconds: 300), () {
                  addHong(6);
                  Future.delayed(const Duration(milliseconds: 4500), () {
                    addHong(7);
                    Future.delayed(const Duration(milliseconds: 4500), () {
                      addHong(8);
                      Future.delayed(const Duration(milliseconds: 4500), () {
                        addHong(9);
                        Future.delayed(const Duration(milliseconds: 5000), () {
                          addHong(10);
                          Future.delayed(const Duration(milliseconds: 5500), () {
                            addHong(11);
                            Future.delayed(const Duration(milliseconds: 5500), () {
                              addHong(12);
                              Future.delayed(const Duration(milliseconds: 5500), () {
                                addHong(13);
                                Future.delayed(const Duration(milliseconds: 7500), () {
                                  addGay(0);
                                  endLevel = 2;
                                });
                              });
                            });
                          });
                        });
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    }
    else if (hong[6].current == CharState.removed && hong[7].current == CharState.removed && hong[8].current == CharState.removed
        && hong[9].current == CharState.removed && hong[10].current == CharState.removed && hong[11].current == CharState.removed && hong[12].current == CharState.removed &&
        hong[13].current == CharState.removed && gay[0].current == CharState.removed && endLevel == 2) {
      hong[6].current = CharState.empty;
      Future.delayed(const Duration(milliseconds: 100), () {
        ko.position = Vector2(100, 100);
        chm.power = 20;

        Future.delayed(const Duration(milliseconds: 1000), () {
          chm.position = Vector2(ko.x + 50, ko.y);
          nextNum = 5;
          Future.delayed(const Duration(milliseconds: 4000), () {
            nextNum = 6;
            Future.delayed(const Duration(milliseconds: 4000), () {
              nextNum = 7;
              Future.delayed(const Duration(milliseconds: 5000), () {
                level.text = "LEVEL 3";
                chm.hp = 30;
                ko.position = Vector2(-999, -999);

                addHong(14);
                Future.delayed(const Duration(milliseconds: 4500), () {
                  addHong(15);
                  Future.delayed(const Duration(milliseconds: 5000), () {
                    addHong(16);
                    Future.delayed(const Duration(milliseconds: 5500), () {
                      addGay(1);
                      Future.delayed(const Duration(milliseconds: 5600), () {
                        addHong(17);
                        Future.delayed(const Duration(milliseconds: 5700), () {
                          addHong(18);
                          Future.delayed(const Duration(milliseconds: 5800), () {
                            addGay(2);
                            Future.delayed(const Duration(milliseconds: 5900), () {
                              addHong(19);
                              Future.delayed(const Duration(milliseconds: 6000), () {
                                addHong(20);
                                Future.delayed(const Duration(milliseconds: 6100), () {
                                  addHong(21);
                                  Future.delayed(const Duration(milliseconds: 6600), () {
                                    addGay(3);
                                    Future.delayed(const Duration(milliseconds: 6200), () {
                                      addHong(22);
                                      Future.delayed(const Duration(milliseconds: 6200), () {
                                        addHong(23);
                                        Future.delayed(const Duration(milliseconds: 6300), () {
                                          addHong(24);
                                          Future.delayed(const Duration(milliseconds: 11000), () {
                                            addHoon(0);
                                            Future.delayed(const Duration(milliseconds: 8000), () {
                                              hoon[0].current = CharState.idle;
                                              addGay(4);
                                              addHong(25);
                                              addHong(26);
                                              Future.delayed(const Duration(milliseconds: 2500), () {
                                                hoon[0].current = CharState.walk;
                                                Future.delayed(const Duration(milliseconds: 5500), () {
                                                  hoon[0].current = CharState.idle;
                                                  addGay(5);
                                                  addHong(27);
                                                  addHong(28);
                                                  Future.delayed(const Duration(milliseconds: 2500), () {
                                                    hoon[0].current = CharState.walk;
                                                    Future.delayed(const Duration(milliseconds: 5500), () {
                                                      hoon[0].current = CharState.idle;
                                                      addGay(6);
                                                      addHong(29);
                                                      addHong(30);
                                                      Future.delayed(const Duration(milliseconds: 2500), () {
                                                        hoon[0].current = CharState.walk;
                                                        endLevel = 3;
                                                      });
                                                    });
                                                  });
                                                });
                                              });
                                            });
                                          });
                                        });
                                      });
                                    });
                                  });
                                });
                              });
                            });
                          });
                        });
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    }
    else if (hong[14].current == CharState.removed && hong[15].current == CharState.removed && hong[16].current == CharState.removed
        && hong[17].current == CharState.removed && hong[18].current == CharState.removed && hong[19].current == CharState.removed && hong[20].current == CharState.removed &&
        hong[21].current == CharState.removed && hong[22].current == CharState.removed && hong[23].current == CharState.removed && hong[24].current == CharState.removed &&
        hong[25].current == CharState.removed && hong[26].current == CharState.removed && hong[27].current == CharState.removed && hong[28].current == CharState.removed &&
        gay[1].current == CharState.removed && gay[2].current == CharState.removed && gay[3].current == CharState.removed && gay[4].current == CharState.removed &&
        gay[5].current == CharState.removed && hoon[0].current == CharState.removed && endLevel == 3) {
      hong[14].current = CharState.empty;
      Future.delayed(const Duration(milliseconds: 1000), () {
        ko.position = Vector2(100, 100);
        addHong(31);
        addGay(7);
        gay[7].size = charSize;
        addHoon(1);
        hoon[1].size = Vector2(50, 64);
        remove(interplayText);
        endingText.text = "Everyone: Happy Birthday Hyunmin!!";
        Future.delayed(const Duration(milliseconds: 4000), () {
          endingText.text = "JooWon: Actually, we was pretending\nto be weird by dressing up\nto surprise you!!";
          Future.delayed(const Duration(milliseconds: 5500), () {
            endingText.text = "JungBin: I'm not human";
            Future.delayed(const Duration(milliseconds: 4000), () {
              endingText.text = "KyungMin: HyunMin Gay\nHappy Birthday~";
              Future.delayed(const Duration(milliseconds: 4300), () {
                endingText.text = "KyungHoon: Byulseul is busy,\nso she decided to congratulate you\nover the phone";
                Future.delayed(const Duration(milliseconds: 5500), () {
                  endingText.text = "(ring...)";
                  Future.delayed(const Duration(milliseconds: 1000), () {
                    endingText.text = "(ring... ring...)";
                    Future.delayed(const Duration(milliseconds: 1000), () {
                      endingText.text = "(Byulseul: hello?)";
                      Future.delayed(const Duration(milliseconds: 1200), () {
                        endingText.text = "(KyungHoon: hi Byulseul!\nSay congratulations to Hyunmin)";
                        Future.delayed(const Duration(milliseconds: 4200), () {
                          endingText.text = "(Byulseul: Happy Birthday Hyunmin!\nI love you..♥)";
                          Future.delayed(const Duration(milliseconds: 4200), () {
                            add(RectangleComponent(
                                paint: Paint()..color = const Color.fromARGB(255, 0, 0, 0),
                                children: [
                                  TextComponent(
                                      text: "Thank you for playing...\nThis game was made by KoJooWon",
                                      textRenderer: interplayTextPaint,
                                      position: Vector2(30, size.y/2)
                                  ),
                                ],
                                size: size,
                                priority: 501
                            ));
                            Future.delayed(const Duration(milliseconds: 10000), () {
                              Restart.restartApp();
                            });
                          });
                        });
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    }

    if (gameStartButton.isPressed) {
      add(chmName);
      add(koName);
      add(chmHP);
      add(chm);
      add(ko);
      add(joystick);
      add(dashSkillButton);
      add(nextButton);
      bg.color = const Color(0xFFbbbbbb);
      remove(gameStartButton);
      remove(title);
      gameStartButton.isPressed = false;
    }

    chmName.position = Vector2(chm.x, chm.y - 57);
    koName.position = Vector2(ko.x, ko.y - 57);
    chmHP.position = Vector2(chm.x, chm.y - 77);
    chmHP.text = "HP : ${chm.hp}";
    dashSkillButton.position = Vector2(size[0] - dialogButtonSize[0] - 40, size[1] - dialogButtonSize[1]-30);
    nextButton.position = Vector2(dashSkillButton.position[0], dashSkillButton.position[1]-dialogButtonSize[1]-30);

    //hong process
    for (var i = 0; i <= 30; i++) {
      hongName[i].position = Vector2(hong[i].x, hong[i].y - 57);
      hongHP[i].position = Vector2(hong[i].x, hong[i].y - 77);
      hongHP[i].text = "HP : ${hong[i].hp}";

      if (hong[i].x > chm.x) {
        hong[i].x -= dt * speed / 1.8;
      } else if (hong[i].x < chm.x) {
        hong[i].x += dt * speed / 1.8;
      } if (hong[i].y > chm.y) {
        hong[i].y -= dt * speed / 1.8;
      } else if (hong[i].y < chm.y) {
        hong[i].y += dt * speed / 1.8;
      }

      if (hong[i].hitPlayer && chm.current == CharState.dash) {
        hong[i].hp -= chm.power;
      }
      if (hong[i].hp <= 0) {
        remove(hong[i]);
        remove(hongName[i]);
        remove(hongHP[i]);
        hong[i].hp = 1;
        hong[i].current = CharState.removed;
      }
    }
    hong[31].position = Vector2(ko.x+100, ko.y);

    //gay process
    for (var i = 0; i <= 6; i++) {
      gayArm[i].position = gay[i].position;
      gayArm[i].angle += 0.5 * dt;
      gayName[i].position = Vector2(gay[i].x, gay[i].y - 70);
      gayHP[i].position = Vector2(gay[i].x, gay[i].y - 90);
      gayHP[i].text = "HP : ${gay[i].hp}";

      if (gay[i].x > chm.x) {
        gay[i].x -= dt * speed / 2;
      } else if (gay[i].x < chm.x) {
        gay[i].x += dt * speed / 2;
      } if (gay[i].y > chm.y) {
        gay[i].y -= dt * speed / 2;
      } else if (gay[i].y < chm.y) {
        gay[i].y += dt * speed / 2;
      }

      if (gay[i].hitPlayer && chm.current == CharState.dash) {
        gay[i].hp -= chm.power;
      }
      if (gay[i].hp <= 0) {
        remove(gay[i]);
        remove(gayArm[i]);
        remove(gayName[i]);
        remove(gayHP[i]);
        gay[i].hp = 100;
        gay[i].current = CharState.removed;
      }
    }
    gay[7].position = Vector2(hong[29].x+100, ko.y);

    //hoon process
    hoonName[0].position = Vector2(hoon[0].x, hoon[0].y - 130);
    hoonHP[0].position = Vector2(hoon[0].x, hoon[0].y - 150);
    hoonHP[0].text = "HP : ${hoon[0].hp}";
    if (hoon[0].x > chm.x) {
      hoon[0].x -= dt * speed / 2.2;
    } else if (hoon[0].x < chm.x) {
      hoon[0].x += dt * speed / 2.2;
    } if (hoon[0].y > chm.y) {
      hoon[0].y -= dt * speed / 2.2;
    } else if (hoon[0].y < chm.y) {
      hoon[0].y += dt * speed / 2.2;
    }
    if (hoon[0].hitPlayer && chm.current == CharState.dash) {
      hoon[0].hp -= chm.power;
    }
    if (hoon[0].hp <= 0) {
      remove(hoon[0]);
      remove(hoonName[0]);
      remove(hoonHP[0]);
      hoon[0].hp = 22000;
      hoon[0].current = CharState.removed;
    }
    hoon[1].position = Vector2(gay[6].x+100, ko.y);
/*    if (hoon.current == CharState.add && timer >= 50) {
      timer = 0;
      hoonAttack = true;
    }
    if (hoonAttack == true && timer >= 8) {
      hoonAttack = false;

      var range = CircleHitbox()
      ..paint = (Paint()..color = Colors.deepOrange)
      ..radius = 300
      ..position = hoon.position
      ..anchor = Anchor.center;
      hoon.current = CharState.idle;
      add(range);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (chm.circleHit == true) {
          chm.hp -= 3;
        }
        remove(range);
      });

      hoonAttack = true;
      timer = 0;
    }*/


    if (chm.hp <= 0) {
      add(RectangleComponent(
        paint: Paint()..color = const Color.fromARGB(255, 0, 0, 0),
        children: [
          TextComponent(
              text: "GAME OVER",
              textRenderer: TextPaint(style: TextStyle(color: BasicPalette.darkRed.color, fontSize: 70, fontFamily: "Bahnschrift", fontWeight: FontWeight.w900)),
              position: Vector2(30, size.y/2)
          ),
        ],
        size: size,
        priority: 500
      ));
      Future.delayed(const Duration(milliseconds: 2500), () {
        Restart.restartApp();
      });
      chm.hp = 100;
    }

    if (dashSkillButton.isPressed && dashSkillButton.canITapDown /*&& chm.wall == false*/) {
      chm.current = CharState.dash;
      if (chm.x <= 0) {
        chm.x = 1;
      } else if (chm.x >= size[0]) {
        chm.x = size[0]-1;
      } else {
        if (chmFlipped) {
          chm.add(MoveEffect.by(Vector2(-1, 0)*dt*1200, EffectController(duration: 0.00000001)));
        } else if (!chmFlipped) {
          chm.add(MoveEffect.by(Vector2(1, 0)*dt*1200, EffectController(duration: 0.00000001)));
        }
      }
    }
    else if (joystick.direction != JoystickDirection.idle && !dashSkillButton.isPressed /*&& chm.wall == false*/) {
       if (chm.x <= 0) {
         chm.x = 1;
       } else if (chm.x >= size[0]) {
         chm.x = size[0]-1;
       } else if (chm.y <= 0) {
         chm.y = 1;
       } else if (chm.y >= size[1]) {
         chm.y = size[1]-1;
       } else {
         chm.position += joystick.relativeDelta * speed * dt;
       }
       chm.current = CharState.walk;
       if (joystick.relativeDelta[0] < 0 && !chmFlipped) {
         chmFlipped = true;
         chm.flipHorizontallyAroundCenter();
       } else if (joystick.relativeDelta[0] > 0 && chmFlipped) {
         chmFlipped = false;
         chm.flipHorizontallyAroundCenter();
       }
    }
      else {
        chm.current = CharState.idle;
      }
    }
}






class Player extends SpriteAnimationGroupComponent with CollisionCallbacks {
  SpriteAnimation playerWalkAnimation;
  SpriteAnimation playerIdleAnimation;
  SpriteAnimation playerDashAnimation;

  Player(
      {required this.playerWalkAnimation,
        required this.playerIdleAnimation,
        required this.playerDashAnimation,
      }): super(
    animations: {
      CharState.walk: playerWalkAnimation,
      CharState.idle: playerIdleAnimation,
      CharState.dash: playerDashAnimation,
    },
    current: CharState.idle,
    position: gameSize / 2 - chmSize / 2,
    size: chmSize,
    anchor: Anchor.center,
    priority: 10,
    children: [
      RectangleHitbox(size: charSize, anchor: Anchor.center)..position = chmSize/2
    ]
  );

  bool isInterplay = false;
  bool canIGetHit = true;
  var circleHit = false;
  var hp = 5;
  var power = 1;

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is NPC) {
      isInterplay = true;
    } else if (other is Enemy && canIGetHit && current != CharState.dash) {
      hp--;
      canIGetHit = false;
      paint = Paint()
        ..color = const Color.fromARGB(100, 255, 255, 255);
      Future.delayed(const Duration(milliseconds: 700), () {
        paint = Paint()
          ..color = const Color.fromARGB(255, 255, 255, 255);
          canIGetHit = true;
      });
    } else if (other is EnemyWeapon && canIGetHit && current != CharState.dash) {
      hp -= 2;
      canIGetHit = false;
      paint = Paint()
        ..color = const Color.fromARGB(100, 255, 255, 255);
      Future.delayed(const Duration(milliseconds: 700), () {
        paint = Paint()
          ..color = const Color.fromARGB(255, 255, 255, 255);
          canIGetHit = true;
      });
    } else if (other is CircleHitbox && current != CharState.dash) {
      circleHit = true;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {

    if (other is NPC) {
      isInterplay = false;
    }
    else if (other is CircleHitbox && current != CharState.dash) {
      circleHit = false;
    }
  }
}






class Enemy extends SpriteAnimationGroupComponent with CollisionCallbacks {
  SpriteAnimation enemyWalkAnimation;
  SpriteAnimation enemyIdleAnimation;
  Vector2 enemySize;
  double hp;

  Enemy({
    required this.enemyWalkAnimation,
    required this.enemyIdleAnimation,
    required this.hp,
    required this.enemySize
  }): super(
      animations: {
        CharState.walk: enemyWalkAnimation,
        CharState.idle: enemyIdleAnimation,
      },
      current: CharState.idle,
      position: gameSize / 2 - charSize / 2,
      size: enemySize,
      anchor: Anchor.center,
    );

  var hitPlayer = false;

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(size: enemySize));
    current = CharState.walk;
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    if (other is Player) {
      hitPlayer = true;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    hitPlayer = false;
  }
}




class EnemyWeapon extends SpriteComponent {
  final weapon;
  final weaponSize;
  final anchor;

  EnemyWeapon({
    required this.weapon,
    required this.weaponSize,
    required this.anchor
  }): super(
    sprite: Sprite(weapon),
    position: gameSize / 2 - weaponSize / 2,
    size: weaponSize,
    anchor: anchor,
  );

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(size: weaponSize));
  }
}





class NPC extends SpriteComponent {
  final image;

  // @override
  // Future<void> onLoad() async {
  //   super.onLoad();
  //
  //   image = await gameRef.images.load("ko/koIdle.png");
  // }

  Future<void> onLoad() async {
    add(RectangleHitbox(isSolid: true, size: chmSize));
  }

  NPC(
      {required this.image,
      }): super(
    sprite: Sprite(image),
    size: charSize,
    anchor: Anchor.center,
  );
}








class DashSkillButton extends SpriteComponent with TapCallbacks {
  bool isPressed = false;
  bool canITapDown = true;

  @override
  void onTapDown(TapDownEvent event) {
    isPressed = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    isPressed = false;
    paint = Paint()
      ..color = const Color.fromARGB(100, 255, 255, 255);
    canITapDown = false;
    Future.delayed(const Duration(seconds: 4), () {
      paint = Paint()
        ..color = const Color.fromARGB(255, 255, 255, 255);
      canITapDown = true;
    });
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    isPressed = false;
    paint = Paint()
      ..color = const Color.fromARGB(100, 255, 255, 255);
    canITapDown = false;
    Future.delayed(const Duration(seconds: 4), () {
      paint = Paint()
        ..color = const Color.fromARGB(255, 255, 255, 255);
      canITapDown = true;
    });
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    isPressed = false;
    paint = Paint()
      ..color = const Color.fromARGB(100, 255, 255, 255);
    canITapDown = false;
    Future.delayed(const Duration(seconds: 4), () {
      paint = Paint()
        ..color = const Color.fromARGB(255, 255, 255, 255);
      canITapDown = true;
    });
  }
}





class GameStartButton extends SpriteComponent with TapCallbacks {
  bool isPressed = false;

  @override
  void onTapDown(TapDownEvent event) {
    isPressed = true;
    paint = Paint()
      ..color = const Color.fromARGB(100, 255, 255, 255);
  }

  @override
  void onTapUp(TapUpEvent event) {
    isPressed = false;
    paint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    isPressed = false;
    paint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255);
  }
}






class BackgroundComponent extends PositionComponent {
  Color color;

  BackgroundComponent(this.color);

  @override
  void render(Canvas canvas) {
    canvas.drawColor(color, BlendMode.src);
  }
}