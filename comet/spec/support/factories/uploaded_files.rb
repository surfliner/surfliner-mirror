FactoryBot.define do
  factory :uploaded_file, class: Hyrax::UploadedFile do
    user
    file { File.open("spec/fixtures/image.jpg") }
  end
end
