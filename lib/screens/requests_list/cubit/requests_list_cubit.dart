import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:reliefflow_frontend_public_app/models/requests/aid_request.dart';
import 'package:reliefflow_frontend_public_app/models/requests/donation_request.dart';

part 'requests_list_state.dart';

class RequestsListCubit extends Cubit<RequestsListState> {
  RequestsListCubit() : super(RequestsListInitial());

  loadDonationRequests() async {
    emit(RequestsListLoading());

    try {
      // emit(RequestsListLoaded(aidRequests donationRequests: donationRequests));
    } catch (e) {
      emit(RequestsListError(message: 'Failed to load aid requests.'));
    }
  }
}
