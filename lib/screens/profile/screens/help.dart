import 'package:flutter/material.dart';
import 'package:suara_mawa/utils/app_colors.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          "Bantuan",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: AppColors.primary,
        ),
      ),


      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _header(),


            const SizedBox(height: 20),


            _sectionTitle("Panduan Penggunaan"),

            _helpCard(
              icon: Icons.person,
              title: "Mengubah Profil",
              description:
              "Buka menu Edit Profil, tekan edit, ubah data kemudian simpan perubahan.",
            ),

            _helpCard(
              icon: Icons.lock,
              title: "Ubah Password",
              description:
              "Masukkan ke menu Ubah Password. Masukkan password lama lalu pwssword baru dan submit.",
            ),

            const SizedBox(height: 20),


            _sectionTitle("Pertanyaan Umum"),


            _faq(
              "Bagaimana jika lupa password?",
              "Gunakan fitur lupa password atau hubungi admin untuk bantuan.",
            ),


            _faq(
              "Data belum berubah setelah update?",
              "Pastikan koneksi internet stabil lalu coba muat ulang aplikasi.",
            ),


            _faq(
              "Upload file gagal?",
              "Periksa izin akses dan pastikan ukuran file sesuai.",
            ),



            const SizedBox(height: 20),


            _sectionTitle("Hubungi Kami"),


            _contactCard(
              icon: Icons.email_outlined,
              title: "Email",
              value: "support@app.com",
            ),


            _contactCard(
              icon: Icons.phone_outlined,
              title: "WhatsApp",
              value: "+6288271220027",
            ),



            const SizedBox(height: 20),


            _sectionTitle("Tentang Aplikasi"),


            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
              ),

              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Nama Aplikasi",
                    style: TextStyle(
                      color: AppColors.subtext1,
                    ),
                  ),

                  SizedBox(height: 4),

                  Text(
                    "Suara Mawa",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),


                  SizedBox(height: 12),


                  Text(
                    "Versi 1.0.0",
                    style: TextStyle(
                      color: AppColors.inactive,
                    ),
                  ),

                ],
              ),
            )

          ],
        ),
      ),
    );
  }



  Widget _header(){

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: AppColors.activePrimary,
        borderRadius: BorderRadius.circular(16),
      ),


      child: Row(

        children: [

          Container(
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),

            child: const Icon(
              Icons.help_outline,
              color: AppColors.primary,
              size: 32,
            ),
          ),


          const SizedBox(width: 16),


          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  "Butuh Bantuan?",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 6),

                Text(
                  "Temukan panduan dan solusi untuk menggunakan aplikasi.",
                  style: TextStyle(
                    color: AppColors.subtext1,
                  ),
                ),

              ],
            ),
          )

        ],
      ),
    );

  }



  Widget _sectionTitle(String text){

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),

      child: Text(
        text,

        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

  }




  Widget _helpCard({
    required IconData icon,
    required String title,
    required String description,
  }){

    return Container(

      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),


      child: Row(

        children: [

          Icon(
            icon,
            color: AppColors.primary,
          ),


          const SizedBox(width: 14),


          Expanded(
            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),


                const SizedBox(height: 5),


                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.subtext1,
                  ),
                )

              ],
            ),
          )

        ],
      ),

    );

  }





  Widget _faq(String question,String answer){

    return ExpansionTile(

      tilePadding: EdgeInsets.zero,

      title: Text(
        question,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),

      children: [

        Padding(
          padding: const EdgeInsets.only(
            bottom: 12,
          ),

          child: Text(
            answer,
            style: const TextStyle(
              color: AppColors.subtext1,
            ),
          ),
        )

      ],
    );

  }





  Widget _contactCard({
    required IconData icon,
    required String title,
    required String value,
  }){

    return Container(

      margin: const EdgeInsets.only(bottom: 10),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),


      child: Row(

        children: [

          Icon(
            icon,
            color: AppColors.primary,
          ),

          const SizedBox(width: 14),


          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(
                title,
                style: const TextStyle(
                  color: AppColors.inactive,
                ),
              ),

              Text(
                value,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ],
          )

        ],
      ),

    );

  }

}