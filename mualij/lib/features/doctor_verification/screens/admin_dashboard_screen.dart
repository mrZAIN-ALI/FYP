import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart'; // ✅ added for routing
import '../controllers/admin_controller.dart';

class AdminDashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingRequests = ref.watch(pendingRequestsProvider);

    return WillPopScope( // ✅ prevent back button
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // ✅ removes back arrow
          title: Text('Admin Dashboard'),
          actions: [
            IconButton(
              onPressed: () {
                Routemaster.of(context).replace('/'); // ✅ logout
              },
              icon: Icon(Icons.logout),
              tooltip: 'Logout',
            ),
          ],
        ),
        body: pendingRequests.when(
          data: (requests) => ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final remarksController = TextEditingController(text: request.remarks ?? '');

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ExpansionTile(
                  title: Text(request.fullName),
                  subtitle: Text('Reg. Type: ${request.registrationType}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Father Name: ${request.fatherName}', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Registration Number: ${request.registrationNumber}'),
                          Text('Issue Date: ${request.issueDate}'),
                          Text('Expiry Date: ${request.expiryDate}'),
                          Text('Status: ${request.status}', style: TextStyle(color: Colors.blue)),
                          const SizedBox(height: 10),
                          Text('Degree Image:', style: TextStyle(fontWeight: FontWeight.w600)),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              request.degreeFileUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Text("Image not available"),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: remarksController,
                            decoration: InputDecoration(
                              labelText: "Remarks",
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 2,
                            onChanged: (value) => request.remarks = value,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          tooltip: 'Approve Request',
                          onPressed: () {
                            ref.read(adminControllerProvider).approveRequest(
                                  request.id,
                                  request.remarks ?? '',
                                );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          tooltip: 'Reject Request',
                          onPressed: () {
                            final trimmedRemarks = request.remarks?.trim() ?? '';
                            if (trimmedRemarks.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Remarks are required to reject a request.')),
                              );
                            } else {
                              ref.read(adminControllerProvider).rejectRequest(
                                    request.id,
                                    trimmedRemarks,
                                  );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
