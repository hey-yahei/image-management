from im2txt.inference import Inferencer

infer = Inferencer(
    ckpt_path="model/model.ckpt-385634",
    vocab_file="model/word_counts.txt"
)

infer.inference(input_dir="../images/")
# infer.write2json("../images/image_info.json", overwrite=True)
infer.write2json("../images/image_info.json", overwrite=False)

print("finished~")