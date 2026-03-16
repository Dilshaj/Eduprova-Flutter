import 'package:eduprova/features/courses/widgets/skeleton_loader.dart';
import 'package:eduprova/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class PaymentMethod {
  final String id;
  final String type;
  final String last4;
  final String expiry;
  bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.last4,
    required this.expiry,
    required this.isDefault,
  });

  PaymentMethod copyWith({
    String? id,
    String? type,
    String? last4,
    String? expiry,
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      type: type ?? this.type,
      last4: last4 ?? this.last4,
      expiry: expiry ?? this.expiry,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class CourseHistoryItem {
  final String id;
  final String courseName;
  final String date;
  final String status;
  final num amount;

  CourseHistoryItem({
    required this.id,
    required this.courseName,
    required this.date,
    required this.status,
    required this.amount,
  });
}

class BillingPaymentsScreen extends StatefulWidget {
  const BillingPaymentsScreen({super.key});

  @override
  State<BillingPaymentsScreen> createState() => _BillingPaymentsScreenState();
}

class _BillingPaymentsScreenState extends State<BillingPaymentsScreen> {
  bool isLoading = true;

  List<PaymentMethod> originalPaymentMethods = [
    PaymentMethod(
      id: '1',
      type: 'visa',
      last4: '4242',
      expiry: '12/28',
      isDefault: true,
    ),
  ];
  List<PaymentMethod> paymentMethods = [];

  List<CourseHistoryItem> courseHistory = [
    CourseHistoryItem(
      id: 'ch1',
      courseName: 'Advanced React Patterns',
      date: 'Oct 24, 2024',
      status: 'Paid',
      amount: 499,
    ),
    CourseHistoryItem(
      id: 'ch2',
      courseName: 'System Design Mastery',
      date: 'Sep 12, 2024',
      status: 'Paid',
      amount: 799,
    ),
  ];

  bool showAddCardModal = false;
  String newCardNumber = '';
  String newCardExpiry = '';
  String newCardName = '';
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    paymentMethods = originalPaymentMethods.map((e) => e.copyWith()).toList();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  String getCardBrand(String type) {
    switch (type) {
      case 'visa':
        return 'VISA';
      case 'mastercard':
        return 'MC';
      case 'amex':
        return 'AMEX';
      case 'rupay':
        return 'RuPay';
      default:
        return 'CARD';
    }
  }

  Color getCardBrandColor(String type) {
    switch (type) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'amex':
        return const Color(0xFF006FCF);
      case 'rupay':
        return const Color(0xFF097969);
      default:
        return const Color(0xFF333333);
    }
  }

  Map<String, Color> getStatusColor(
    String status,
    AppDesignExtension themeExt,
    ColorScheme colorScheme,
  ) {
    switch (status) {
      case 'Paid':
        return {
          'bg': themeExt.successBackgroundColor,
          'text': themeExt.successColor,
          'border': themeExt.successColor.withValues(alpha: 0.3),
        };
      case 'Pending':
        return {
          'bg': themeExt.warningColor.withValues(alpha: 0.1),
          'text': themeExt.warningColor,
          'border': themeExt.warningColor.withValues(alpha: 0.3),
        };
      case 'Refunded':
        return {
          'bg': themeExt.errorBackgroundColor,
          'text': colorScheme.error,
          'border': colorScheme.error.withValues(alpha: 0.3),
        };
      default:
        return {
          'bg': themeExt.skeletonBase,
          'text': themeExt.secondaryText,
          'border': themeExt.borderColor,
        };
    }
  }

  String detectCardType(String number) {
    String cleaned = number.replaceAll(' ', '');
    if (cleaned.startsWith('4')) return 'visa';
    if (cleaned.startsWith('5') || cleaned.startsWith('2')) return 'mastercard';
    if (cleaned.startsWith('3')) return 'amex';
    if (cleaned.startsWith('6') || cleaned.startsWith('8')) return 'rupay';
    return 'visa';
  }

  String formatCardNumber(String text) {
    String cleaned = text.replaceAll(RegExp(r'\D'), '');
    List<String> chunks = [];
    for (int i = 0; i < cleaned.length; i += 4) {
      int end = (i + 4 < cleaned.length) ? i + 4 : cleaned.length;
      chunks.add(cleaned.substring(i, end));
    }
    return chunks.join(' ');
  }

  String formatExpiry(String text) {
    String cleaned = text.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length >= 2) {
      return '${cleaned.substring(0, 2)}/${cleaned.substring(2)}';
    }
    return cleaned;
  }

  void handleAddCard() {
    String cleanedNumber = newCardNumber.replaceAll(' ', '');
    if (cleanedNumber.length < 13 || cleanedNumber.length > 19) {
      _showAlert('Invalid Card', 'Please enter a valid card number.');
      return;
    }
    if (newCardExpiry.length < 5) {
      _showAlert('Invalid Expiry', 'Please enter a valid expiry date (MM/YY).');
      return;
    }
    if (newCardName.trim().isEmpty) {
      _showAlert('Missing Name', 'Please enter the cardholder name.');
      return;
    }

    PaymentMethod newCard = PaymentMethod(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: detectCardType(cleanedNumber),
      last4: cleanedNumber.substring(cleanedNumber.length - 4),
      expiry: newCardExpiry,
      isDefault: paymentMethods.isEmpty,
    );

    setState(() {
      paymentMethods.add(newCard);
      hasChanges = true;
      showAddCardModal = false;
      newCardNumber = '';
      newCardExpiry = '';
      newCardName = '';
    });
  }

  void setDefaultCard(String cardId) {
    setState(() {
      for (var card in paymentMethods) {
        card.isDefault = card.id == cardId;
      }
      hasChanges = true;
    });
  }

  void removeCard(String cardId) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    final colorScheme = theme.colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Card'),
        content: const Text(
          'Are you sure you want to remove this payment method?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: themeExt.secondaryText),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                paymentMethods.removeWhere((c) => c.id == cardId);
                if (paymentMethods.isNotEmpty &&
                    !paymentMethods.any((c) => c.isDefault)) {
                  paymentMethods.first.isDefault = true;
                }
                hasChanges = true;
              });
            },
            child: Text('Remove', style: TextStyle(color: colorScheme.error)),
          ),
        ],
      ),
    );
  }

  void handleInvoice(CourseHistoryItem item) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    final colorScheme = theme.colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invoice'),
        content: Text(
          'Invoice for "${item.courseName}"\n\nDate: ${item.date}\nAmount: ₹${item.amount}\nStatus: ${item.status}\n\nInvoice will be sent to your registered email.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: themeExt.secondaryText),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showAlert('Sent!', 'Invoice has been sent to your email.');
            },
            child: Text(
              'Send to Email',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void handleDiscard() {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    final colorScheme = theme.colorScheme;
    if (hasChanges) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Discard Changes'),
          content: const Text('Are you sure you want to discard all changes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(color: themeExt.secondaryText),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  paymentMethods = originalPaymentMethods
                      .map((e) => e.copyWith())
                      .toList();
                  hasChanges = false;
                });
                Navigator.pop(context);
              },
              child: Text(
                'Discard',
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void handleSaveChanges() {
    setState(() {
      originalPaymentMethods = paymentMethods.map((e) => e.copyWith()).toList();
      hasChanges = false;
    });
    _showAlert('Saved', 'Your payment settings have been saved successfully.');
  }

  void _showAlert(String title, String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK', style: TextStyle(color: colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(
    AppDesignExtension themeExt,
    ColorScheme colorScheme,
  ) {
    if (paymentMethods.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: themeExt.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: themeExt.borderColor),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.credit_card_outlined,
              size: 40,
              color: themeExt.borderColor,
            ),
            const SizedBox(height: 8),
            Text(
              'No payment methods added',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: themeExt.secondaryText,
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => setState(() => showAddCardModal = true),
              child: Text(
                '+ Add your first card',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: paymentMethods.map((card) {
        return GestureDetector(
          onTap: () => setDefaultCard(card.id),
          onLongPress: () => removeCard(card.id),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: themeExt.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: card.isDefault
                    ? colorScheme.primary
                    : themeExt.borderColor,
                width: card.isDefault ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: themeExt.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 36,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    color: getCardBrandColor(card.type),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    getCardBrand(card.type),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${getCardBrand(card.type).substring(0, 1)}${getCardBrand(card.type).substring(1).toLowerCase()} ending in ${card.last4}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Expires ${card.expiry}',
                        style: TextStyle(
                          fontSize: 13,
                          color: themeExt.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (card.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: themeExt.successColor,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'DEFAULT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: themeExt.successColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeExt = theme.extension<AppDesignExtension>()!;
    final colorScheme = theme.colorScheme;

    if (isLoading) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: themeExt.scaffoldBackgroundColor,
          body: const SafeArea(child: BillingPaymentsSkeleton()),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: theme.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: themeExt.scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.arrow_back,
                              size: 22,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ).copyWith(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Billing & Payments',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage payment methods and history.',
                          style: TextStyle(
                            fontSize: 14,
                            color: themeExt.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                      ).copyWith(bottom: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PAYMENT METHODS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: themeExt.secondaryText,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              InkWell(
                                onTap: () =>
                                    setState(() => showAddCardModal = true),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 18,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'ADD NEW',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildPaymentMethods(themeExt, colorScheme),

                          const SizedBox(height: 28),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 18,
                                color: themeExt.secondaryText,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'COURSE HISTORY',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: themeExt.secondaryText,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Table Header
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: themeExt.borderColor),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    'COURSE',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: themeExt.secondaryText,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'DATE',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: themeExt.secondaryText,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'STATUS',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: themeExt.secondaryText,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'ACTION',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: themeExt.secondaryText,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Table Rows
                          if (courseHistory.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.receipt_long,
                                      size: 40,
                                      color: themeExt.borderColor,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'No purchase history yet',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: themeExt.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...courseHistory.map((item) {
                              var statusColors = getStatusColor(
                                item.status,
                                themeExt,
                                colorScheme,
                              );
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: themeExt.borderColor.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        item.courseName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        item.date,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: themeExt.secondaryText,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: statusColors['bg'],
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            border: Border.all(
                                              color: statusColors['border']!,
                                            ),
                                          ),
                                          child: Text(
                                            item.status,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: statusColors['text'],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: InkWell(
                                          onTap: () => handleInvoice(item),
                                          child: Text(
                                            'Invoice',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Buttons
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ).copyWith(bottom: 34),
                  decoration: BoxDecoration(
                    color: themeExt.cardColor,
                    border: Border(
                      top: BorderSide(color: themeExt.borderColor),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: themeExt.shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: InkWell(
                          onTap: handleDiscard,
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            child: const Text(
                              'DISCARD',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9CA3AF),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: handleSaveChanges,
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  // colorScheme.primary,
                                  // colorScheme.secondary,
                                  // Color(0xFF8B5CF6),
                                  // Color(0xFF6366F1),
                                  // Color(0xFFEC4899),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'SAVE CHANGES',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Add Card Modal
              if (showAddCardModal)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeExt.cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 44),
                    child: Material(
                      color: Colors.transparent,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Add New Card',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              InkWell(
                                onTap: () =>
                                    setState(() => showAddCardModal = false),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: themeExt.borderColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 18,
                                    color: themeExt.secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          Text(
                            'Card Number',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: themeExt.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller:
                                TextEditingController(text: newCardNumber)
                                  ..selection = TextSelection.fromPosition(
                                    TextPosition(offset: newCardNumber.length),
                                  ),
                            onChanged: (text) {
                              setState(() {
                                newCardNumber = formatCardNumber(text);
                              });
                            },
                            decoration: InputDecoration(
                              hintText: '1234 5678 9012 3456',
                              hintStyle: TextStyle(color: themeExt.borderColor),
                              filled: true,
                              fillColor: themeExt.scaffoldBackgroundColor
                                  .withValues(alpha: 0.5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: themeExt.borderColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: themeExt.borderColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                ),
                              ),
                              contentPadding: const EdgeInsets.all(14),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 19,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                              letterSpacing: 1,
                            ),
                            buildCounter:
                                (
                                  context, {
                                  required currentLength,
                                  required isFocused,
                                  maxLength,
                                }) => null,
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Expiry Date',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: themeExt.secondaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller:
                                          TextEditingController(
                                              text: newCardExpiry,
                                            )
                                            ..selection =
                                                TextSelection.fromPosition(
                                                  TextPosition(
                                                    offset:
                                                        newCardExpiry.length,
                                                  ),
                                                ),
                                      onChanged: (text) {
                                        setState(() {
                                          newCardExpiry = formatExpiry(text);
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'MM/YY',
                                        hintStyle: TextStyle(
                                          color: themeExt.borderColor,
                                        ),
                                        filled: true,
                                        fillColor: themeExt
                                            .scaffoldBackgroundColor
                                            .withValues(alpha: 0.5),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: themeExt.borderColor,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: themeExt.borderColor,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.all(
                                          14,
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      maxLength: 5,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurface,
                                      ),
                                      buildCounter:
                                          (
                                            context, {
                                            required currentLength,
                                            required isFocused,
                                            maxLength,
                                          }) => null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Cardholder Name',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: themeExt.secondaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextField(
                                      onChanged: (text) => newCardName = text,
                                      decoration: InputDecoration(
                                        hintText: 'John Doe',
                                        hintStyle: TextStyle(
                                          color: themeExt.borderColor,
                                        ),
                                        filled: true,
                                        fillColor: themeExt
                                            .scaffoldBackgroundColor
                                            .withValues(alpha: 0.5),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: themeExt.borderColor,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide(
                                            color: themeExt.borderColor,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.all(
                                          14,
                                        ),
                                      ),
                                      textCapitalization:
                                          TextCapitalization.words,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          InkWell(
                            onTap: handleAddCard,
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primary,
                                    colorScheme.secondary,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Add Card',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
