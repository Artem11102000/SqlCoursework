using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Data.SqlClient;

namespace WorkingWithDB
{
    public partial class Form1 : Form
    {
        SqlConnection sqlConnection;
        public Form1()
        {
            InitializeComponent();
        }

        private void файдToolStripMenuItem_Click(object sender, EventArgs e)
        {

        }

        private async void Form1_Load(object sender, EventArgs e)
        {
            string connectionString = @"Data Source=DESKTOP-TTBJ1VQ;Initial Catalog=Libary;Integrated Security=True";

            sqlConnection = new SqlConnection(connectionString);

            await sqlConnection.OpenAsync();

            SqlDataReader sqlReader = null;

            SqlCommand command = new SqlCommand("SELECT * FROM [Rooms]", sqlConnection);
            try
            {
                sqlReader = await command.ExecuteReaderAsync();

                while (await sqlReader.ReadAsync())
                {
                    listBox1.Items.Add(Convert.ToString(sqlReader["id"]) + "     " + Convert.ToString(sqlReader["num"]) + "     " + Convert.ToString(sqlReader["name"]) + "     " + Convert.ToString(sqlReader["vmesto"]));
                }
            }
            catch(Exception ex)
            {
                MessageBox.Show(ex.Message.ToString(), ex.Source.ToString(), MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                if (sqlReader != null)
                    sqlReader.Close();
            }
        }

        private void выходToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (sqlConnection != null && sqlConnection.State != ConnectionState.Closed)
                sqlConnection.Close();
        }

        private async void button1_Click(object sender, EventArgs e)
        {
            SqlCommand command = new SqlCommand("INSERT INTO [Rooms] (num, name, vmesto)VALUES(@num, @name, @vmesto)", sqlConnection);

            command.Parameters.AddWithValue("num", textBox1.Text);

            command.Parameters.AddWithValue("name", textBox2.Text);

            command.Parameters.AddWithValue("vmesto", textBox7.Text);

            await command.ExecuteNonQueryAsync();
        }

        private async void обновитьToolStripMenuItem_Click(object sender, EventArgs e)
        {
            listBox1.Items.Clear();

            SqlDataReader sqlReader = null;

            SqlCommand command = new SqlCommand("SELECT * FROM [Rooms]", sqlConnection);
            try
            {
                sqlReader = await command.ExecuteReaderAsync();

                while (await sqlReader.ReadAsync())
                {
                    listBox1.Items.Add(Convert.ToString(sqlReader["id"]) + "     " + Convert.ToString(sqlReader["num"]) + "     " + Convert.ToString(sqlReader["name"]) + "     " + Convert.ToString(sqlReader["vmesto"]));
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message.ToString(), ex.Source.ToString(), MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                if (sqlReader != null)
                    sqlReader.Close();
            }
    }

        private async void button3_Click(object sender, EventArgs e)
        {
            SqlCommand command = new SqlCommand("Update [Rooms] set [num] = @num, [name] = @name, [vmesto] = @vmesto WHERE [id] = @id",sqlConnection);

            command.Parameters.AddWithValue("num", textBox5.Text);

            command.Parameters.AddWithValue("name", textBox6.Text);

            command.Parameters.AddWithValue("vmesto", textBox8.Text);

            command.Parameters.AddWithValue("id", textBox4.Text);


            await command.ExecuteNonQueryAsync();
        }

        private async void button2_Click(object sender, EventArgs e)
        {
            SqlCommand command = new SqlCommand("DELETE FROM [Rooms] WHERE [id] = @id", sqlConnection);

            command.Parameters.AddWithValue("id", textBox3.Text);

            await command.ExecuteNonQueryAsync();
        }
    }
}
