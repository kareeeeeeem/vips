import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class InviteFriendsController extends GetxController {
  // Referral code
  var referralCode = 'VIPS2024'.obs;

  // Stats
  var totalInvited = 0.obs;
  var totalJoined = 0.obs;
  var totalEarned = 0.obs;

  // Invited friends list
  var invitedFriends = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() {
    // Simulate loading user data
    // Dans une vraie app, vous feriez un appel API ici

    referralCode.value = 'VIPS2024'; // Code unique de l'utilisateur
    totalInvited.value = 12;
    totalJoined.value = 8;
    totalEarned.value = 200; // 200K diamants

    // Exemple de friends invités
    invitedFriends.value = [
      {'name': 'Sarah Johnson', 'joined': true, 'date': '2024-01-15'},
      {'name': 'Mike Chen', 'joined': true, 'date': '2024-01-14'},
      {'name': 'Emma Wilson', 'joined': false, 'date': '2024-01-10'},
      {'name': 'Alex Rodriguez', 'joined': true, 'date': '2024-01-08'},
      {'name': 'Lisa Brown', 'joined': false, 'date': '2024-01-05'},
    ];
  }

  String get shareMessage {
    return '''
🎁 Join VIPs Club with my code and we both get rewarded!

Use my referral code: ${referralCode.value}

You'll get 10,000 diamants as a welcome bonus!
I'll get 25,000 diamants when you join.

Download now: [App Link]
''';
  }

  void shareGeneric() async {
    try {
      await Share.share(shareMessage, subject: 'Join VIPs Club');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to share at this time',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void shareViaWhatsApp() async {
    try {
      // Pour WhatsApp, vous pouvez utiliser un package comme url_launcher
      // ou share_plus avec des paramètres spécifiques
      await Share.share(shareMessage, subject: 'Join VIPs Club');

      // Alternative avec url_launcher:
      // final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(shareMessage)}';
      // if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      //   await launchUrl(Uri.parse(whatsappUrl));
      // }
    } catch (e) {
      Get.snackbar(
        'Error',
        'WhatsApp not available',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void shareViaMessenger() async {
    try {
      await Share.share(shareMessage, subject: 'Join VIPs Club');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Messenger not available',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void shareViaEmail() async {
    try {
      // Pour email, utilisez url_launcher ou mailto
      await Share.share(
        shareMessage,
        subject: 'Join VIPs Club - Get 10,000 Diamants!',
      );

      // Alternative avec url_launcher:
      // final emailUrl = 'mailto:?subject=${Uri.encodeComponent("Join VIPs Club")}&body=${Uri.encodeComponent(shareMessage)}';
      // if (await canLaunchUrl(Uri.parse(emailUrl))) {
      //   await launchUrl(Uri.parse(emailUrl));
      // }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Email not available',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void copyReferralCode() {
    // Cette fonction est déjà gérée dans la vue avec Clipboard.setData
    // mais vous pouvez aussi la mettre ici pour centraliser la logique
  }

  void refreshData() {
    // Rafraîchir les données depuis l'API
    loadUserData();
  }

  // Méthode pour inviter un ami par email
  void inviteByEmail(String email) async {
    try {
      // Appel API pour envoyer une invitation
      // await apiService.sendInvitation(email, referralCode.value);

      Get.snackbar(
        'Success',
        'Invitation sent to $email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Rafraîchir la liste
      refreshData();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send invitation',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Méthode pour inviter un ami par numéro de téléphone
  void inviteByPhone(String phone) async {
    try {
      // Appel API pour envoyer une invitation par SMS
      // await apiService.sendSMSInvitation(phone, referralCode.value);

      Get.snackbar(
        'Success',
        'Invitation sent to $phone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      refreshData();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send invitation',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class InviteFriendsView extends GetView<InviteFriendsController> {
  const InviteFriendsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(InviteFriendsController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Invite Friends',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 20.h),

            // Hero Illustration
            _buildHeroSection(),

            SizedBox(height: 32.h),

            // Rewards Info
            _buildRewardsSection(),

            SizedBox(height: 24.h),

            // Referral Code Card
            _buildReferralCodeCard(),

            SizedBox(height: 24.h),

            // Share Buttons
            _buildShareButtons(),

            SizedBox(height: 32.h),

            // Invite Stats
            _buildInviteStats(),

            SizedBox(height: 24.h),

            // Invited Friends List
            _buildInvitedFriendsList(),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        children: [
          // Illustration/Icon
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: Color(0xFFFAFAFA),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.group_add_outlined,
              size: 60.sp,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 20.h),

          Text(
            'Invite Friends & Earn',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -1,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 12.h),

          Text(
            'Share your code with friends and both get rewarded when they join',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Color(0xFFE8E8E8), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRewardItem(
              icon: Icons.card_giftcard_outlined,
              title: 'You Get',
              amount: '25,000',
              subtitle: 'diamants',
            ),
          ),

          Container(width: 1, height: 60.h, color: Color(0xFFE8E8E8)),

          Expanded(
            child: _buildRewardItem(
              icon: Icons.redeem_outlined,
              title: 'Friend Gets',
              amount: '10,000',
              subtitle: 'diamants',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem({
    required IconData icon,
    required String title,
    required String amount,
    required String subtitle,
  }) {
    return Column(
      children: [
        Icon(icon, size: 28.sp, color: Colors.black),
        SizedBox(height: 8.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          amount,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.8,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildReferralCodeCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
            child: Text(
              'Your Referral Code',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Color(0xFFE8E8E8), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          controller.referralCode.value,
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            letterSpacing: 2,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Tap to copy',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: controller.referralCode.value),
                    );
                    Get.snackbar(
                      'Copied!',
                      'Referral code copied to clipboard',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.black,
                      colorText: Colors.white,
                      duration: Duration(seconds: 2),
                      margin: EdgeInsets.all(16.w),
                      borderRadius: 12.r,
                    );
                  },
                  icon: Icon(Icons.copy_outlined, color: Colors.black),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButtons() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
            child: Text(
              'Share via',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: _buildShareButton(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: controller.shareGeneric,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildShareButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'WhatsApp',
                  onTap: controller.shareViaWhatsApp,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Row(
            children: [
              Expanded(
                child: _buildShareButton(
                  icon: Icons.messenger_outline,
                  label: 'Messenger',
                  onTap: controller.shareViaMessenger,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildShareButton(
                  icon: Icons.mail_outline,
                  label: 'Email',
                  onTap: controller.shareViaEmail,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Color(0xFFE8E8E8), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.sp, color: Colors.black),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteStats() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Color(0xFFE8E8E8), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              label: 'Invited',
              value: controller.totalInvited,
            ),
          ),
          Container(width: 1, height: 40.h, color: Color(0xFFE8E8E8)),
          Expanded(
            child: _buildStatItem(
              label: 'Joined',
              value: controller.totalJoined,
            ),
          ),
          Container(width: 1, height: 40.h, color: Color(0xFFE8E8E8)),
          Expanded(
            child: _buildStatItem(
              label: 'Earned',
              value: controller.totalEarned,
              suffix: 'K',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required RxInt value,
    String suffix = '',
  }) {
    return Column(
      children: [
        Obx(
          () => Text(
            '${value.value}$suffix',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.8,
            ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInvitedFriendsList() {
    return Obx(() {
      if (controller.invitedFriends.isEmpty) {
        return _buildEmptyState();
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
              child: Text(
                'Invited Friends',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            ...controller.invitedFriends.map(
              (friend) => _buildFriendItem(friend),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFriendItem(Map<String, dynamic> friend) {
    bool isJoined = friend['joined'] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Color(0xFFE8E8E8), width: 1),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: Color(0xFFFAFAFA),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                friend['name'][0].toUpperCase(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend['name'],
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  isJoined ? 'Joined • Earned 25K diamants' : 'Invited',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color:
                        isJoined ? Colors.green.shade700 : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Status badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isJoined ? Colors.black : Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              isJoined ? 'Joined' : 'Pending',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: isJoined ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(40.w),
      decoration: BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 48.sp, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text(
            'No friends invited yet',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start sharing your code to earn rewards',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
