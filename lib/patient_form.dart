import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mobile/components/custom_gender_options.dart';
import 'package:mobile/components/date_input.dart';
import 'package:mobile/extensions/extensions.dart';
import 'package:mobile/services/database_service.dart';
import 'components/custom_text_input_field.dart';
import 'components/custom_form_title.dart';
import 'components/custom_form_input_container.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

final TextEditingController nameController = TextEditingController();
final TextEditingController cpfController = TextEditingController();
final TextEditingController phoneController = TextEditingController();
final TextEditingController birthdayController = TextEditingController();
final TextEditingController genderController = TextEditingController();

final _cpfFormatter = MaskTextInputFormatter(
  mask: '###.###.###-##',
  filter: {"#": RegExp(r'[0-9]')},
);

final _cellPhoneFormater = MaskTextInputFormatter(
  mask: '(##) #####-####',
  filter: {"#": RegExp(r'[0-9]')},
);

class PatientForm extends StatefulWidget {
  const PatientForm({super.key});

  @override
  State<StatefulWidget> createState() => _PatientFormState();
}

String? name, cpf, phoneNumber, gender, birthday;
bool _showGenderWarning = false;


class _PatientFormState extends State<PatientForm> {
  final _formkey = GlobalKey<FormState>();

  final DatabaseService _databaseService = DatabaseService.instance;

  Future<void> selectDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1914),
      lastDate: DateTime.now(),
    );

    initializeDateFormatting("pt_BR", null);

    if (_picked != null) {
      setState(() {
        birthday = DateFormat.yMd("pt_BR").format(_picked);
        birthdayController.text = DateFormat.yMd("pt_BR").format(_picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Form(
              key: _formkey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInUp(
                      duration: Duration(microseconds: 1500),
                      child: CustomFormTitle(title: "Cadastrar novo Paciente"),
                    ),
                    SizedBox(height: 30),
                    FadeInUp(
                      duration: Duration(milliseconds: 1700),
                      child: CustomFormInputContainer(
                        inputFields: [
                          CustomTextInputField(
                            hintText: "Digite o nome completo",
                            controller: nameController,
                            inputFormatters: [],
                            validator: (value) {
                              if (!value!.isValidPatientName) {
                                return "Digite um nome válido";
                              }
                              return null;
                            },
                            onSaved:
                                (value) => setState(() {
                                  if (value != null) {
                                    name =
                                        value[0].toUpperCase() +
                                        value.substring(1);
                                  }
                                }),
                          ),
                          CustomTextInputField(
                            hintText: "Digite o CPF",
                            controller: cpfController,
                            validator: (value) {
                              if (!value!.isCPFValid) {
                                return "Digite um CPF válido. Apenas números.";
                              }
                              return null;
                            },
                            inputFormatters: [_cpfFormatter],
                            onSaved:
                                (value) => setState(() {
                                  cpf = value;
                                }),
                          ),
                          CustomTextInputField(
                            hintText: "Digite o telefone",
                            controller: phoneController,
                            inputFormatters: [_cellPhoneFormater],
                            validator: (value) {
                              if (!value!.isValidPhone) {
                                return "Digite um número válido. Apenas números.";
                              }
                              return null;
                            },
                            onSaved:
                                (value) => setState(() {
                                  phoneNumber = value;
                                }),
                          ),
                          CustomDateInput(
                            controller: birthdayController,
                            labelText: 'Data de nascimento',
                            validator: (value) {
                              if (!value!.isValidPatientName) {
                                return "Selecione a data de nascimento";
                              }
                              return null;
                            },
                            onTap: selectDate,
                            onSaved: (value) => setState(() {}),
                          ),
                          GenderButton(
                            onChangedGenderButton: (String? value) {
                              setState(() {
                                gender = value!;
                              });
                            },
                          ),
                          if (_showGenderWarning)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 8.0, left: 10.0, bottom: 8.0),
                                  child: Text(
                                    "Escolha uma opção",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    FadeInUp(
                      duration: Duration(milliseconds: 1900),
                      child: MaterialButton(
                        onPressed: () {
                          if (gender == null) {
                            setState(() {
                              _showGenderWarning = true;
                            });
                          } else {
                            setState(() {
                              _showGenderWarning = false;
                            });
                          }
                          if (
                            _formkey.currentState!.validate() &&
                              !_showGenderWarning
                            ) {
                            _formkey.currentState!.save();

                            _databaseService.savePatient(name!, cpf!, phoneNumber!, birthday!, gender!);
                          
                            print(
                              "Patient { ${name}, ${phoneNumber}, ${cpf}, ${gender}, ${birthday} }",
                            );
                          }
                        },
                        color: Color.fromRGBO(49, 39, 79, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        height: 50,
                        child: Center(
                          child: Text(
                            "Salvar",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
