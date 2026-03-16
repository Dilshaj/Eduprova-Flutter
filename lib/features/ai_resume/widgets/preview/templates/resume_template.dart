import 'package:flutter/material.dart';
import '../../../models/resume_data.dart';
import 'azurill.dart';
import 'bronzor.dart';
import 'chikorita.dart';
import 'ditgar.dart';
import 'ditto.dart';
import 'gengar.dart';
import 'glalie.dart';
import 'kakuna.dart';
import 'lapras.dart';
import 'leafish.dart';
import 'onyx.dart';
import 'pikachu.dart';
import 'rhyhorn.dart';

class ResumeTemplates {
  static const allTemplates = [
    'azurill',
    'bronzor',
    'chikorita',
    'ditgar',
    'ditto',
    'gengar',
    'glalie',
    'kakuna',
    'lapras',
    'leafish',
    'onyx',
    'pikachu',
    'rhyhorn',
  ];

  static Widget getTemplate(
    String name, {
    required int pageIndex,
    required PageLayout pageLayout,
    required ResumeData resume,
  }) {
    return switch (name.toLowerCase()) {
      'azurill' => AzurillTemplate(
        pageIndex: pageIndex,
        pageLayout: pageLayout,
        resume: resume,
      ),
      'bronzor' => BronzorTemplate(
        pageIndex: pageIndex,
        pageLayout: pageLayout,
        resume: resume,
      ),
      'chikorita' => ChikoritaTemplate(
        pageIndex: pageIndex,
        pageLayout: pageLayout,
        resume: resume,
      ),
      'ditgar' => DitgarTemplate(
        pageIndex: pageIndex,
        pageLayout: pageLayout,
        resume: resume,
      ),
      'ditto' => DittoTemplate(
        pageIndex: pageIndex,
        pageLayout: pageLayout,
        resume: resume,
      ),
      'gengar' => GengarTemplate(
        pageIndex: pageIndex,
        pageLayout: pageLayout,
        resume: resume,
      ),
      'glalie' => GlalieTemplate(
        pageIndex: pageIndex,
        pageLayout: pageLayout,
        resume: resume,
      ),
      'kakuna' => KakunaTemplate(
        pageIndex: pageIndex,
        pageLayout: pageLayout,
        resume: resume,
      ),
      'lapras' => LaprasTemplate(
        pageIndex: pageIndex,
        pageLayout: pageLayout,
        resume: resume,
      ),
      'leafish' => LeafishTemplate(
        pageIndex: pageIndex,
        pageLayout: pageLayout,
        resume: resume,
      ),
      'onyx' => OnyxTemplate(
        pageIndex: pageIndex,
        pageLayout: pageLayout,
        resume: resume,
      ),
      'pikachu' => PikachuTemplate(
        pageIndex: pageIndex,
        pageLayout: pageLayout,
        resume: resume,
      ),
      'rhyhorn' => RhyhornTemplate(
        pageIndex: pageIndex,
        pageLayout: pageLayout,
        resume: resume,
      ),
      _ => ChikoritaTemplate(
        pageIndex: pageIndex,
        pageLayout: pageLayout,
        resume: resume,
      ),
    };
  }
}
