import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
import 'chat_detailscreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchChatController = TextEditingController();
  final ChatService _chatService = ChatService();
  String? _currentUserEmail;
  String _searchText = '';

  String _stringValue(dynamic value) => (value ?? '').toString().trim();

  String _fullName(Map<String, dynamic> user) {
    final firstName = _stringValue(user['firstName'] ?? user['fName']);
    final lastName = _stringValue(user['lastName'] ?? user['lName']);
    final fullName = [firstName, lastName].where((name) => name.isNotEmpty).join(' ');
    return fullName.isNotEmpty ? fullName : 'Unknown User';
  }

  String _initials(Map<String, dynamic> user) {
    final fullName = _fullName(user);
    final parts = fullName.split(RegExp(r'\s+'));
    if (parts.length == 1 && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
    }
    return '?';
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUserEmail();
  }

  Future<void> _loadCurrentUserEmail() async {
    final userData = await UserService().getUserData();
    setState(() {
      _currentUserEmail = userData['email'];
    });
  }

  @override
  void dispose() {
    _searchChatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFFF5F5F5);
    final cardColor = const Color(0xFFE7E1DD);
    final borderColor = const Color(0xFFBDBDBD);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const CustomText(
          text: 'Chat',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 23.w),
              child: TextField(
                controller: _searchChatController,
                textInputAction: TextInputAction.search,
                onChanged: (value) {
                  setState(() {
                    _searchText = value.toLowerCase();
                  });
                },
                style: const TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Search chat...',
                  hintStyle: const TextStyle(color: Colors.black54),
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  suffixIcon: (_searchChatController.text.isNotEmpty)
                      ? IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.cancel, color: Colors.black54),
                          onPressed: () {
                            setState(() {
                              _searchChatController.clear();
                              _searchText = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.transparent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: borderColor, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Colors.black87, width: 1.5),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatService.getUsersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: ScreenUtil().screenHeight * 0.6,
                    padding: EdgeInsets.all(16.sp),
                    child: const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    height: ScreenUtil().screenHeight * 0.6,
                    padding: EdgeInsets.all(16.sp),
                    child: Center(
                      child: CustomText(
                        text: 'Error loading users',
                        fontSize: 16.sp,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    height: ScreenUtil().screenHeight * 0.6,
                    padding: EdgeInsets.all(16.sp),
                    child: Center(
                      child: CustomText(
                        text: 'No users found!',
                        fontSize: 16.sp,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }

                final users = snapshot.data!.where((user) {
                  final email = _stringValue(user['email']).toLowerCase();
                  final fullName = _fullName(user).toLowerCase();

                  final isNotCurrentUser = email != _currentUserEmail?.toLowerCase();
                  final matchesSearch = fullName.contains(_searchText) ||
                      email.contains(_searchText);

                  return isNotCurrentUser && matchesSearch;
                }).toList();

                if (users.isEmpty) {
                  return Container(
                    height: ScreenUtil().screenHeight * 0.6,
                    padding: EdgeInsets.all(16.sp),
                    child: Center(
                      child: CustomText(
                        text: 'No messages found...',
                        fontSize: 16.sp,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final fullName = _fullName(user);
                    final email = _stringValue(user['email']);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              currentUserEmail: _currentUserEmail ?? '',
                              tappedUser: user,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.orange.shade700,
                              child: CustomText(
                                text: _initials(user),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: fullName,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  SizedBox(height: 4.h),
                                  CustomText(
                                    text: email.isEmpty ? 'No email' : email,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}